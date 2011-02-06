require 'fileutils'

module HTMLVideoAutomator
  class Job
    def initialize
      @videos = Array.new
      @id = get_new_id
    end
    
    def start
      @start_time = Time.now
      try_lock if Config['environment'] == 'production'
      
      files = list_dropbox
      files.each do |file|
        video = Video.new(file)
        @videos.push(video)
      end
      
      @videos.each do |video|
        $log.info "Processing #{video.filename}"
        
        video.tasks[:valid] = :working
        next unless report video.valid?
        
        video.tasks[:mp4] = :working
        next unless report Worker.encode video, :format => 'mp4'
        video.tasks[:webm] = :working
        next unless report Worker.encode video, :format => 'webm'
        video.tasks[:poster] = :working
        next unless report Worker.gen_poster video # TODO: , :format => 'png'
        video.tasks[:html] = :working
        next unless report Worker.gen_html video

        # TODO:
        # scp encoded movies and html doc to www server
        # scp source movies to archive server
        # Clean local files
      end
      
      report(true, :final)
      
      unlock if Config['environment'] == 'production'
    end
    
    private
    
    def list_dropbox
      # TODO: May need to filter input here...
      # but for now let's go with all files, ffmpeg's hungry.
      # And what about people placing extension-less files?
      files = Dir.glob("#{Config.path('dropbox')}/*") # TODO: use `find` instead => get all files in subdirectories
      $log.info "#{files.count} files found in the dropbox"
      return files
    end
    
    def get_new_id
      jobs = Dir.glob("#{Config.path('jobs')}/*").count
      job_id = jobs + 1
      begin
        FileUtils.touch("#{Config.path('jobs')}/#{job_id}")
      rescue Exception => e
        $log.fatal "Error getting new job id: #{e}"
        abort("Error getting new job id: #{e}")
      end
      $log.debug "Got job id ##{job_id}"
      return job_id
    end
    
    def report(result, type = :in_progress)
      Worker.gen_job_report(@id, @videos, @start_time, type)
      return result
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