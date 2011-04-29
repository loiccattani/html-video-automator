require 'fileutils'

module HTMLVideoAutomator
  class Job
    attr_accessor :report_url
    
    def initialize
      @videos = Array.new
      @id = get_new_id
      @report_url = "#{Config['app_root_url']}/jobs/job-report-#{@id}.html" # TODO: Move that sub path in config
      @pub_url = "#{Config['pub_url']}/#{@id}"
      @some_task_failed = false
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
      
    end
    
    def start
      try_lock if Config['enable_mutex']
      $log.info "Job ##{@id} Started"
      
      move_videos_to_workbench
      
      prepare_content_server      
      prepare_sources_server
      
      @videos.each do |video|
        $log.info "Processing #{video.filename}"
        video.pub_url = @pub_url
        
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
      
      unlock if Config['enable_mutex']
      $log.info "No more work! Will take a nap..."
    end
    
    private
    
    def do_task(task, video)
      video.tasks[task] = :working
      $log.debug "Tagged task '#{task.to_s}' to 'working' for #{video.name}"
      report
      
      case task
      when :validate
        result = video.valid?
      when :encode_mp4
        result = video.encode 'mp4'
      when :encode_webm
        result = video.encode 'webm'
      when :gen_poster
        result = video.gen_poster
      when :gen_html
        result = video.gen_html
      when :publish
        result = publish video
      when :archive
        result = archive video
      end
      
      # If failed, move that video back to the dropbox immediately.
      # So that the user can repair, or replace it and launch a new job without waiting.
      unless result
        FileUtils.mv video.path, "#{Config.path('dropbox')}/"
        $log.warn "Failed video #{video.filename} moved back to dropbox"
        @some_task_failed = true
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
        abort
      end
      
      $log.debug "Got job id ##{job_id}"
      return job_id
    end
    
    def report(type = :in_progress)
      elapsed = seconds_to_human_time(Time.now - @start_time)
      pub_url = @pub_url
      job_id = @id
      videos = @videos
      
      if type == :final
        unless @some_task_failed
          type = :done
        else
          type = :failed
        end
      end
      
      begin
        erb = ERB.new File.new(File.dirname(__FILE__) + '/../../views/job-report.rhtml').read, nil, "%"
        File.open("#{Config.path('public')}/jobs/job-report-#{@id}.html", 'w') do |f|
          f.write erb.result(binding)
        end
      rescue Exception => e
        $log.error "Unexpected error building job report: #{e}"
        return false
      end
      
      $log.debug "Built job report"
      return true
    end
    
    def prepare_content_server
      # Create job-id directory
      cmd = "ssh -q -i ~/.ssh/#{Config['ssh_key']} #{Config['content_server']['user']}@#{Config['content_server']['host']} \'mkdir -p #{Config['content_server']['path']}/#{@id}\'"
      unless system(cmd)
        $log.fatal "Error creating job directory on content server"
        abort
      end
      $log.debug "Content server ready"
    end
    
    def prepare_sources_server
      # Create job-id directory
      cmd = "ssh -q -i ~/.ssh/#{Config['ssh_key']} #{Config['sources_server']['user']}@#{Config['sources_server']['host']} \'mkdir -p #{Config['sources_server']['path']}/#{@id}\'"
      unless system(cmd)
        $log.fatal "Error creating job directory on sources server"
        abort
      end
      $log.debug "Sources server ready"
    end
    
    def move_videos_to_workbench
      @videos.each do |video|
        new_path = "#{Config.path('workbench')}/#{video.filename}"
        begin
          FileUtils.mv video.path, new_path
          video.path = new_path
        rescue Exception => e
          # If the file is missing at this point, it's likely that another job stealed the file in a race condition.
          # Pretty rare, so delete the video so that job may continue.
          $log.warn "Wow! Race condition occured! Deleted #{video.filename} so we can finish that job. (#{e})"
          @videos.delete(video)
        end
      end
      $log.debug "Moved #{@videos.count} videos to workbench"
    end
    
    def publish(video)
      cmd = "scp -q -i ~/.ssh/#{Config['ssh_key']} #{video.deliverables.join(' ')} #{Config['content_server']['user']}@#{Config['content_server']['host']}:#{Config['content_server']['path']}/#{@id}/"
      if system(cmd)
        $log.info "Published #{video.name} to #{Config['content_server']['host']}"
        return true
      else
        $log.error video.fail_reason = "Error publishing #{video.name}"
        return false
      end
    end
    
    def archive(video)
      cmd = "scp -q -i ~/.ssh/#{Config['ssh_key']} '#{video.path}' #{Config['sources_server']['user']}@#{Config['sources_server']['host']}:#{Config['sources_server']['path']}/#{@id}/"
      if system(cmd)
        $log.info "Archived #{video.name} source to #{Config['sources_server']['host']}"
        return true
      else
        $log.error video.fail_reason = "Error archiving #{video.name} source"
        return false
      end
    end
    
    def clean_local_files(video)
      $log.info "Cleaning local source and deliverables for #{video.name}"
      FileUtils.rm video.deliverables
      FileUtils.rm video.path
    end
    
    def try_lock
      begin
        FileUtils.mkdir '/tmp/hva-lock'
      rescue Exception => e
        $log.fatal "HVA already running. Aborting..."
        abort
      end
      $log.debug "Successfully locked mutex"
    end

    def unlock
      FileUtils.rmdir '/tmp/hva-lock'
      $log.debug "Unlocked mutex" 
    end
  end
end