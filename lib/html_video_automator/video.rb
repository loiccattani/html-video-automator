require 'digest/sha1'
require 'iconv'

module HTMLVideoAutomator
  class Video
    attr_accessor :path, :relative_path, :filename, :name, :digest, :size, :maxed_size, :duration, :file_size, :tasks, :fail_reason, :deliverables
    attr_writer :tasks, :fail_reason, :deliverables
    
    def initialize(path)
      @path = path
      @relative_path = nil # TODO: Relative path from dropbox
      @filename = File.basename(@path)
      @name = transliterate(@filename[/(.*)\.(.*)/,1]) # Isolate filename from extension #TODO: test this against plenty of filenames...
      @digest = Digest::SHA1.hexdigest(@path)
      @ffmpeg_info = get_ffmpeg_info
      @size = get_size
      @maxed_size = get_maxed_size
      @duration = get_duration
      @file_size = File.size(@path)
      @tasks = { :validate => :unknown, :encode_mp4 => :unknown, :encode_webm => :unknown, :gen_poster => :unknown, :gen_html => :unknown, :publish => :unknown, :archive => :unknown }
      @fail_reason = nil
      @deliverables = Array.new
    end
    
    def valid?
      match = @ffmpeg_info[/Stream[^\n\r]+Video/]
      if match
        $log.debug "Video stream found"
      else
        $log.error @fail_reason = 'No video stream found'
      end
      return match
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
    
    def aspect_ratio(width, height)
      return width.to_f / height.to_f
    end

  end
end