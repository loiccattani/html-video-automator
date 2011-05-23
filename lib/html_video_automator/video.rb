require 'digest/sha1'
require 'iconv'
require 'logger'

module HTMLVideoAutomator
  class Video
    attr_accessor :path, :relative_path, :filename, :name, :digest, :valid, :size, :maxed_size, :duration, :file_size, :tasks, :fail_reason, :deliverables, :pub_url
    attr_writer :tasks, :fail_reason, :deliverables, :pub_url
    
    def initialize(path)
      @path = path
      @filename = File.basename(@path)
      @name = transliterate(@filename) # Transliterate and isolate filename from extension
      @digest = Digest::SHA1.hexdigest(@path)
      @tasks = { :validate => :unknown, :encode_mp4 => :unknown, :encode_webm => :unknown, :gen_poster => :unknown, :gen_html => :unknown, :publish => :unknown, :archive => :unknown }
      @fail_reason = nil
      @deliverables = Array.new
      @pub_url = nil
      @ffmpeg_log = Logger.new(Config.path('ffmpeg_log_file'), 'daily')
      @ffmpeg_log.level = Logger::INFO
      # Single and Double quotes in filenames may lead to command injection.
      if @path.include?('"') or @path.include?("'")
        @valid = false
        @fail_reason = "Invalid filename, will be renamed safely..."
      else
        load_info
      end
    end
    
    def load_info
      @ffmpeg_info = get_ffmpeg_info
      @valid = valid?
      @size = get_size
      @maxed_size = get_maxed_size
      @duration = get_duration
      @file_size = File.size(@path)
    end
    
    def valid?
      match = @ffmpeg_info[/Stream[^\n\r]+Video/]
      if match
        $log.debug "Video stream found"
        return true
      else
        $log.error @fail_reason = 'No video stream found'
        return false
      end
    end
    
    def encode(format)
      start_time = Time.now
      wxh = "#{@maxed_size[:width]}x#{@maxed_size[:height]}"

      case format
      when 'mp4'
        filename = "#{@name}.mp4"
        output_path = Config.path('deliverables') + "/" + filename
        cmd = "ffmpeg -y -i '#{@path}' -threads 0 -f mp4 -vcodec libx264 -preset slow -vpre ipod640 -b 1200k -acodec libfaac -ab 160k -ac 2 -s #{wxh} #{output_path}"
        @ffmpeg_log.info "FFmpeg started for #{filename}:\n#{cmd}\n"
        status = system("#{cmd} 2>> #{Config.path('ffmpeg_log_file')}")
        @ffmpeg_log.info "FFmpeg ended processing for #{filename}\n########\n"
        $log.debug "FFmpeg returned #{status}"
      when 'webm'
        filename = "#{@name}.webm"
        output_path = Config.path('deliverables') + "/" + filename
        cmd = "ffmpeg -y -i '#{@path}' -threads 8 -f webm -vcodec libvpx -g 120 -level 216 -qmax 50 -qmin 10 -rc_buf_aggressivity 0.95 -b 1200k -acodec libvorbis -aq 80 -ac 2 -s #{wxh} #{output_path}"
        @ffmpeg_log.info "Launched ffmpeg for #{filename} with:\n#{cmd}\n"
        status = system("#{cmd} 2>> #{Config.path('ffmpeg_log_file')}")
        @ffmpeg_log.info "FFmpeg ended processing for #{filename}\n########\n"
        $log.debug "FFmpeg returned #{status}"
      end
      
      if status
        if File.exist?(output_path)
          @deliverables.push output_path
          $log.debug "Added deliverable #{output_path}"
          $log.info "Done encoding #{filename}. Elapsed #{(Time.now - start_time).to_i}s"
          return true
        else
          $log.error @fail_reason = "FFmpeg was unable to encode #{@name}"
          return false
        end
      else
        $log.error @fail_reason = "FFmpeg returned an error encoding #{filename}"
        return false
      end
    end
    
    def gen_poster
      filename = "#{@name}.png"
      output_path = Config.path('deliverables') + "/" + filename
      wxh = "#{@maxed_size[:width]}x#{@maxed_size[:height]}"
      poster_time = seconds_to_duration(duration_to_seconds(@duration) * 0.5)
      
      cmd = "ffmpeg -i '#{@path}' -r 1 -ss #{poster_time} -vcodec png -vframes 1 -f image2 -s #{wxh} #{output_path}"
      @ffmpeg_log.info "Launched ffmpeg for #{filename} with:\n#{cmd}\n"
      status = system("#{cmd} 2>> #{Config.path('ffmpeg_log_file')}")
      @ffmpeg_log.info "FFmpeg ended processing for #{filename}\n########\n"
      $log.debug "FFmpeg returned #{status}"
      
      if status
        if File.exist?(output_path)
          @deliverables.push output_path
          $log.debug "Added deliverable #{output_path}"
          $log.info "Done poster for #{@name}"
          return true
        else
          $log.error @fail_reason = "FFmpeg was unable to create poster for #{@name}"
          return false
        end
      else
        $log.error @fail_reason = "FFmpeg returned an error creating poster for #{@name}"
        return false
      end
    end
    
    def gen_html
      name = @name
      filename = "#{@name}.html"
      output_path = Config.path('deliverables') + "/" + filename
      size = @maxed_size
      pub_url = @pub_url
      jahia_size = get_jahia_size
      
      begin
        erb = ERB.new File.new(File.dirname(__FILE__) + '/../../views/video.rhtml').read, nil, "%"
        File.open("#{output_path}", 'w') do |f|
          f.write erb.result(binding)
        end
      rescue Exception => e
        $log.error @fail_reason = "Unexpected error building HTML document for #{@name}: #{e}"
        return false
      end
      
      @deliverables.push output_path
      $log.debug "Added deliverable #{output_path}"
      $log.info "Built HTML document for #{@name}"
      return true
    end
        
    private
    
    def get_ffmpeg_info
      str = `ffmpeg -i "#{@path}" 2>&1` # ffmpeg outputs to stderr!
      Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
    end
    
    def get_size
      width = @ffmpeg_info[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 1].to_i
      height = @ffmpeg_info[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 2].to_i
      return :width => width, :height => height
    end
    
    def get_duration()
      @ffmpeg_info[/Duration:\s([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{2})/, 1]
    end
    
    def get_maxed_size
      # Accept a size hash {:width, :height} and returns a maximized "wxh" value. Scaling down the size
      # if needed but not scale it up. Also keep its aspect ratio.

      w = @size[:width]
      h = @size[:height]
      mw = Config['max_width']
      mh = Config['max_height']
      r = aspect_ratio(w, h)

      $log.debug "Original size: #{w}x#{h} (#{r.round(2)})"

      if w > mw and r >= 1.0
        w = mw
        h = [w / r, mh].min.to_i
      elsif h > mh and r < 1.0
        h = mh
        w = [h * r, mw].min.to_i
      end

      r = aspect_ratio(w, h)

      $log.debug "Maxed size: #{w}x#{h} (#{r.round(2)})"

      return :width => w, :height => h
    end
    
    def get_jahia_size
      # Return the video size maxed by 565px wide
      jahia_max_width = 565
      
      if @maxed_size[:width] > jahia_max_width
        w = jahia_max_width
        r = aspect_ratio(@maxed_size[:width], @maxed_size[:height])
        h = (jahia_max_width / r).to_i
        return :width => w, :height => h 
      else
        return @maxed_size
      end
    end
    
    def aspect_ratio(width, height)
      return width.to_f / height.to_f
    end

  end
end
