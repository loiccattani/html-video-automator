# coding: utf-8

require "erb"

module HTMLVideoAutomator
  class Dropbox
    class << self
      def load
        videos = Array.new
        paths = Dir.glob("#{Config.path('dropbox')}/**/*")
        $log.debug "Searching path in dropbox at \"#{Config.path('dropbox')}\""
        
        paths.each do |path|
          $log.debug "Found #{path}"
          videos.push Video.new(path)
        end
        
        $log.info "#{paths.count} files found in the dropbox"
        return videos
      end
      
      def show
        videos = self.load
        script_url = Config['app_root_url'] + "/dropbox/job-launcher.rb"
        
        begin
          erb = ERB.new File.new(File.dirname(__FILE__) + '/../../views/dropbox.rhtml').read, nil, "%"
          return erb.result(binding)
        rescue Exception => e
          $log.error "Unexpected error rendering dropbox view: #{e}"
          return false
        end
      end
    end
  end
end