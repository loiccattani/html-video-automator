require 'yaml'

module HTMLVideoAutomator
  class Config
    class << self
      def load
        config_file = File.dirname(__FILE__) + '/../../config/config.yml'

        abort("Can't find config file!") unless File.exists?(config_file)
        
        @config = YAML.load_file(config_file)
      end
      
      def [](*path)
        c = @config
        path.each{|p|
          c = c[p]
          return if c.nil?
        }
        c
      end
      
      def path(path)
        if path.chr == '/' # Absolute path
          return path
        elsif path == 'home' # App's home path (Which may be like '~/work/hva')
          return File.expand_path(@config['home']) 
        else # Relative path from home
          return File.expand_path("#{@config['home']}/#{@config['path']}")
        end
      end
      
    end
  end
end
