require 'logger'

module HTMLVideoAutomator
  class Runner
    def initialize
      Config.load
      
      $log = Logger.new(Config['log_file'], 'daily')
      $log.level = Logger::INFO
      
      @job = HTMLVideoAutomator::Job.new
    end
    
    def run
      @job.start
    end
  end
end
