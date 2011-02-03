require 'yaml'

module HTMLVideoAutomator
  class Config
    class << self
      def load
        dev_config_file = File.dirname(__FILE__) + '/../../config/config.yml'
        prod_config_file = File.dirname(__FILE__) + '/etc/hva.config.yml'

        if File.exists?(prod_config_file)
          config_file = prod_config_file
        elsif File.exists?(dev_config_file)
          config_file = dev_config_file
        else
          abort("Can't find config file!")
        end
        
        @config = YAML.load_file(config_file)['global']
        @config.merge! YAML.load_file(config_file)[@config['environment']]
      end
      
      def [](*path)
        c = @config
        path.each{|p|
          c = c[p]
          return if c.nil?
        }
        c
      end
      
    end
  end
end
