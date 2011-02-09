require 'logger'
require 'cgi'

module HTMLVideoAutomator
  class Runner
    def initialize
      Config.load
      
      $log = Logger.new(Config.path('log_file'), 'daily')
      $log.level = Logger::INFO
      
      @cgi = CGI.new
      
      $log.info "HTML Video Automator Started"
    end
    
    def run
      if @cgi.request_method == 'GET'
        show_dropbox
      elsif @cgi.request_method == 'POST' and ! @cgi.params['files'].empty?
        launch_job(cgi.params['files'])
      else
        $log.fatal "Unhandled method or missing parameters"
      end
    end
    
    def show_dropbox
      $log.info "Showing dropbox"
      @cgi.out{Dropbox.show}
    end
    
    def launch_job(files)
      $log.info "Trying to launch job"
      @job = HTMLVideoAutomator::Job.new
      if @job.prepare(files)
        @cgi.header("status" => "302", "location" => @job.report_url) # Initial job report ready, redirect to it!
        $log.info "Job ##{job.id} Started"
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
