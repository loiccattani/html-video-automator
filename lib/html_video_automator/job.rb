require 'fileutils'

module HTMLVideoAutomator
  class Job
    attr_accessor :report_url
    
    def initialize
      @videos = Array.new
      @id = get_new_id
      @report_url = "#{Config['app_root_url']}/jobs/job-report-#{@id}.html" # TODO: Move that sub path in config (also in worker.rb)
    end
    
    def prepare(hashes)
      @start_time = Time.now
      dropbox_videos = Dropbox.load
      
      # Compare each files in dropbox with POSTed hashes and push matches to @videos
      dropbox_videos.each do |video|
        if hashes.include? video.digest
          @videos.push video
        end
      end
      
      if @videos.count == hashes.count
        report # Generate initial report for CGI request response redirect
        return true # return true only if each hash matches with a file in the dropbox
      else
        return false
      end
      
      # TODO: Think where to lock mutex
    end
    
    def start
      try_lock if Config['enable_mutex'] == true
      $log.info "Job ##{@id} Started"
      
      prepare_publish_server
      prepare_archive_server
      
      @videos.each do |video|
        $log.info "Processing #{video.filename}"
        
        next unless do_task :validate, video
        
        next unless do_task :encode_mp4, video
        next unless do_task :encode_webm, video
        next unless do_task :gen_poster, video
        next unless do_task :gen_html, video
        
        next unless do_task :publish, video
        next unless do_task :archive, video
        
        clean_local_files(video)
      end
      
      report(:final)
      
      unlock if Config['enable_mutex'] == true
      $log.info "No more work! Will take a nap..."
    end
    
    private
    
    def do_task(task, video)
      video.tasks[task] = :working
      $log.debug "Tagged #{task.to_s} to working for #{video.name}"
      report
      
      case task
      when :validate
        result = video.valid?
      when :encode_mp4
        result = Worker.encode video, :format => 'mp4'
      when :encode_webm
        result = Worker.encode video, :format => 'webm'
      when :gen_poster
        result = Worker.gen_poster video
      when :gen_html
        result = Worker.gen_html video
      when :publish
        result = publish video
      when :archive
        result = archive video
      end
      
      update_task(video, task, result)
      return result
    end
    
    def update_task(video, task, result)
      video.tasks[task] = result ? :done : :failed
    end
    
    def get_new_id
      job_id_file = "#{Config.path('home')}/config/.job_id"
      job_id = File.exists?(job_id_file) ? File.open(job_id_file, 'r').read.to_i + 1 : 1
      
      begin
        File.open(job_id_file, 'w') do |f|
          f.write job_id
        end
      rescue Exception => e
        $log.fatal "Error getting new job id: #{e}"
        abort("Error getting new job id: #{e}")
      end
      
      $log.debug "Got job id ##{job_id}"
      return job_id
    end
    
    def report(type = :in_progress)
      Worker.gen_job_report(@id, @videos, @start_time, type)
    end
    
    def clean_local_files(video)
      $log.info "Cleaning local source and deliverables for #{video.name}"
      FileUtils.rm video.deliverables
      FileUtils.rm video.path
    end
    
    def prepare_publish_server
      # Create job-id directory
      cmd = "ssh -q -i ~/.ssh/#{Config['ssh_key']} #{Config['publish']['user']}@#{Config['publish']['server']} \'mkdir -p #{Config['publish']['path']}/job-#{@id}\'"
      unless system(cmd)
        $log.fatal "Error creating job directory on publish server"
        abort
      end
    end
    
    def prepare_archive_server
      # Create job-id directory
      cmd = "ssh -q -i ~/.ssh/#{Config['ssh_key']} #{Config['archive']['user']}@#{Config['archive']['server']} \'mkdir -p #{Config['archive']['path']}/job-#{@id}\'"
      unless system(cmd)
        $log.fatal "Error creating job directory on archive server"
        abort
      end
    end
    
    def publish(video)
      cmd = "scp -q -i ~/.ssh/#{Config['ssh_key']} #{video.deliverables.join(' ')} #{Config['publish']['user']}@#{Config['publish']['server']}:#{Config['publish']['path']}/job-#{@id}/"
      if system(cmd)
        $log.info "Published #{video.name} to #{Config['publish']['server']}"
        return true
      else
        $log.error video.fail_reason = "Error publishing #{video.name}"
        return false
      end
    end
    
    def archive(video)
      cmd = "scp -q -i ~/.ssh/#{Config['ssh_key']} '#{video.path}' #{Config['archive']['user']}@#{Config['archive']['server']}:#{Config['archive']['path']}/job-#{@id}/"
      if system(cmd)
        $log.info "Archived #{video.name} source to #{Config['archive']['server']}"
        return true
      else
        $log.error video.fail_reason = "Error archiving #{video.name} source"
        return false
      end
    end
    
    def try_lock
      begin
        FileUtils.mkdir '/tmp/hva-lock'
      rescue Exception => e
        $log.info "HVA already running. Aborting..."
        abort("HVA already running. #{e}")
      end
      $log.debug "Successfully locked mutex"
    end

    def unlock
      FileUtils.rmdir '/tmp/hva-lock'
      $log.debug "Unlocked mutex" 
    end
  end
end