require 'fileutils'

module HTMLVideoAutomator
  class Job
    def initialize
      
    end
    
    def start
      $log.info "HTML Video Automator Started"
      
      try_lock if Config['environment'] == 'production'
      
      # TODO: continue here...
      
      unlock if Config['environment'] == 'production'
      
      $log.info "No more work! Will take a nap..."
    end
    
    private
    
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