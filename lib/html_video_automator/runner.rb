require 'logger'

module HTMLVideoAutomator
  class Runner
    def initialize
      Config.load
      
      $log = Logger.new(Config.path('log_file'), 'daily')
      $log.level = Logger::INFO
      
      @job = HTMLVideoAutomator::Job.new
    end
    
    def run
      $log.info "HTML Video Automator Started"
      @job.start
      $log.info "No more work! Will take a nap..."
    end
  end
end
