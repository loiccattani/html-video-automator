require "erb"

module HTMLVideoAutomator
  class Worker
    class << self
      
      def encode(video, params)
        start_time = Time.now
        wxh = "#{video.maxed_size[:width]}x#{video.maxed_size[:height]}"

        case params[:format]
        when 'mp4'
          filename = "#{video.name}.mp4"
          path = Config.path('deliverables') + "/" + filename
          status = system("ffmpeg -y -i '#{video.path}' -threads 0 -f mp4 -vcodec libx264 -vpre slow -vpre ipod640 -b 1200k -acodec libfaac -ab 160000 -ac 2 -s #{wxh} #{path} 2>> #{Config.path('ffmpeg_log_file')}")
        when 'webm'
          filename = "#{video.name}.webm"
          path = Config.path('deliverables') + "/" + filename
          status = system("ffmpeg -y -i '#{video.path}' -threads 0 -f webm -vcodec libvpx -g 120 -level 216 -qmax 50 -qmin 10 -rc_buf_aggressivity 0.95 -b 1200k -acodec libvorbis -aq 80 -ac 2 -s #{wxh} #{path} 2>> #{Config.path('ffmpeg_log_file')}")
        end
        
        if status
          video.deliverables.push path
          $log.info "Done encoding #{filename}. Elapsed #{(Time.now - start_time).to_i}s"
          return true
        else
          $log.error video.fail_reason = "ffmpeg returned an error encoding #{filename}"
          return false
        end
      end
      
      def gen_poster(video)
        filename = "#{video.name}.png"
        path = Config.path('deliverables') + "/" + filename
        wxh = "#{video.maxed_size[:width]}x#{video.maxed_size[:height]}"
        poster_time = seconds_to_duration(duration_to_seconds(video.duration) * 0.5)

        if system("ffmpeg -i '#{video.path}' -r 1 -ss #{poster_time} -vcodec png -vframes 1 -f image2 -s #{wxh} #{path} 2>> #{Config.path('ffmpeg_log_file')}")
          video.deliverables.push path
          $log.info "Done poster for #{video.name}"
          return true
        else
          $log.error video.fail_reason = "ffmpeg returned an error creating poster for #{video.name}"
          return false
        end
      end
      
      def gen_html(video)
        name = video.name
        filename = "#{video.name}.html"
        path = Config.path('deliverables') + "/" + filename
        size = video.maxed_size
        pub_url = Config['pub_url']
        
        begin
          erb = ERB.new File.new(File.dirname(__FILE__) + '/../../views/video.rhtml').read, nil, "%"
          File.open("#{path}", 'w') do |f|
            f.write erb.result(binding)
          end
        rescue Exception => e
          $log.error video.fail_reason = "Unexpected error building HTML document for #{video.name}: #{e}"
          return false
        end
        
        video.deliverables.push path
        $log.info "Built HTML document for #{video.name}"
        return true
      end
    end
  end
end