module HTMLVideoAutomator
  class Video
    attr_accessor :path, :filename, :name, :size, :maxed_size
    attr_writer :status
    
    def initialize(path)
      @path = path
      @filename = File.basename(@path)
      @name = @filename[/(.*)\.(.*)/,1] # Isolate filename from extension #TODO: test this against plenty of filenames...
      @size = get_size
      @maxed_size = get_maxed_size
    end
    
    def valid?
      match = ffmpeg_info[/Stream[^\n\r]+Video/]
      $log.debug match ? "Video stream found" : "No video stream found" 
      return match
    end
    
    private
    
    def get_size
      width = ffmpeg_info[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 1].to_i
      height = ffmpeg_info[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 2].to_i
      return :width => width, :height => height
    end
    
    def ffmpeg_info
      @ffmpeg_info = `ffmpeg -i #{@path} 2>&1` if ! defined? @ffmpeg_info # ffmpeg outputs to stderr!
      return @ffmpeg_info
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

      return "#{w}x#{h}"
    end
    
    def aspect_ratio(width, height)
      return width.to_f / height.to_f
    end

  end
end