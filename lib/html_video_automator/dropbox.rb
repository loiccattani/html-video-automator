module HTMLVideoAutomator
  class Dropbox
    class << self
      def list
        files = Dir.glob("#{Config.path('dropbox')}/**")
        $log.info "#{files.count} files found in the dropbox"
        return files
      end
      
      def show
        #Worker.gen_job_report(@id, @videos, @start_time, type)
        return false
      end
    end
  end
end