require 'fileutils'

module HTMLVideoAutomator
  class Job
    def initialize
      
    end
    
    def start
      $log.info "HTML Video Automator Started"
      try_lock if Config['environment'] == 'production'
      
      paths = list_dropbox
      paths.each do |path|
        
        $log.info "Processing #{File.basename(path)}"
        
        video = Video.new(path)
        next unless video.valid?
        
        #next if ! encode file, :format => 'mp4', :size => wxh
        #next if ! encode file, :format => 'webm', :size => wxh
        #next if ! gen_poster file, :size => wxh
        #next if ! gen_html name, :pub_url => @config['pub_url'], :size => size

        # TODO:
        # scp encoded movies and html doc to www server
        # scp source movies to archive server
        # Clean local files
      end
      
      unlock if Config['environment'] == 'production'
      $log.info "No more work! Will take a nap..."
    end
    
    private
    
    def list_dropbox
      # TODO: May need to filter input here...
      # but for now let's go with all files, ffmpeg's hungry.
      # And what about people placing extension-less files?
      files = Dir.glob("#{Config['dropbox']}/*") # TODO: use `find` instead => get all files in subdirectories
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