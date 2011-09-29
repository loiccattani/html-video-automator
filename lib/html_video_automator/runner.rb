# coding: utf-8

require 'logger'
require 'cgi'

module HTMLVideoAutomator
  class Runner
    def initialize
      Config.load
      
      $log = Logger.new(Config.path('log_file'), 'daily')
      $log.level = Logger::INFO # Change this to Logger::DEBUG for more logging
      
      @cgi = CGI.new
      
      $log.info "HTML Video Automator Started"
    end
    
    def run
      if @cgi.request_method == 'GET'
        show_dropbox
      elsif @cgi.request_method == 'POST' and ! @cgi.params['hashes'].empty?
        launch_job(@cgi.params['hashes'])
      elsif @cgi.request_method == 'POST' and @cgi.params['hashes'].empty?
        $log.warn "Can't launch job: No files selected"
        show_dropbox
      else
        $log.fatal "Unhandled method or missing parameters"
      end
    end
    
    def show_dropbox
      $log.info "Showing dropbox"
      @cgi.out{Dropbox.show}
    end
    
    def launch_job(hashes)
      $log.info "Trying to launch job"
      hd_mode = @cgi.params['hd_mode'][0] == "1"
      @job = HTMLVideoAutomator::Job.new
      if @job.prepare(hashes, hd_mode)
        @cgi.out("status" => "303", "Connection" => "close", "Content-Length" => 1, "Location" => @job.report_url) {' '} # Initial job report ready, redirect to it!
        # Why 303? http://en.wikipedia.org/wiki/HTTP_303
        # Works in FF 4 only with Content-Lenght > 0 and Connection: close
        @job.start
      else
        $log.error "Can't launch job, bad hashes or missing files in dropbox"
        # TODO: Add an error message somewhere to add feedback to the dropbox view
        show_dropbox
      end
    end
  end
end
