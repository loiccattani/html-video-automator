require 'fileutils'

module HTMLVideoAutomator
  class Job
    def initialize
      @videos = Array.new
    end
    
    def start
      try_lock if Config['environment'] == 'production'
      
      files = list_dropbox
      files.each do |file|
        $log.info "Processing #{File.basename(file)}"
        
        video = Video.new(file)
        @videos.push(video)
        next unless video.valid?
        
        #next unless Worker.encode video, :format => 'mp4'
        #next unless Worker.encode video, :format => 'webm'
        #next unless Worker.gen_poster video # TODO: , :format => 'png'
        #next unless Worker.gen_html video

        # TODO:
        # scp encoded movies and html doc to www server
        # scp source movies to archive server
        # Clean local files
      end
      
      # TODO: Generate html job report
      
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