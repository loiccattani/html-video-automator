require 'logger'

module HTMLVideoAutomator
  class Runner
    def initialize
      Config.load
      
      $log = Logger.new(Config.path('log_file'), 'daily')
      $log.level = Logger::INFO
    end
    
    def show_dropbox
      $log.info "Show dropbox"
    end
    
    def launch_job(files)
      $log.info "Launch job"
      @job = HTMLVideoAutomator::Job.new
      if @job.prepare(files)
        $log.info "HTML Video Automator Job ##{job.id} Started"
        @job.start
        $log.info "No more work! Will take a nap..."
      else
        $log.error "Can't launch job, bad or missing files hashes"
        # TODO: Add an error message somewhere to add feedback to the dropbox view
        show_dropbox
      end
    end
  end
end
