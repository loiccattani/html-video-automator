module HTMLVideoAutomator
  class Dropbox
    class << self
      def load
        videos = Array.new
        paths = Dir.glob("#{Config.path('dropbox')}/**/*")
        
        paths.each do |path|
          videos.push Video.new(path)
        end
        
        $log.info "#{files.count} files found in the dropbox"
        return videos
      end
      
      def show
        videos = self.load
        
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