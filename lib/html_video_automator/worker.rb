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
          status = system("ffmpeg -y -i #{video.path} -threads 0 -f mp4 -vcodec libx264 -vpre slow -vpre ipod640 -b 1200k -acodec libfaac -ab 160000 -ac 2 -s #{wxh} #{Config.path('outbox')}/#{filename} 2>> #{Config.path('ffmpeg_log_file')}")
        when 'webm'
          filename = "#{video.name}.webm"
          status = system("ffmpeg -y -i #{video.path} -threads 0 -f webm -vcodec libvpx -g 120 -level 216 -qmax 50 -qmin 10 -rc_buf_aggressivity 0.95 -b 1200k -acodec libvorbis -aq 80 -ac 2 -s #{wxh} #{Config.path('outbox')}/#{filename} 2>> #{Config.path('ffmpeg_log_file')}")
        end
        
        if status
          $log.info "Done encoding #{filename}. Elapsed #{(Time.now - start_time).to_i}s"
          return true
        else
          $log.error video.fail_reason = "ffmpeg returned an error encoding #{filename}"
          return false
        end
      end
      
      def gen_poster(video)
        filename = "#{video.name}.jpg"
        wxh = "#{video.maxed_size[:width]}x#{video.maxed_size[:height]}"

        if system("ffmpeg -i #{video.path} -r 1 -ss 00:00:15.00 -vcodec mjpeg -vframes 1 -f image2 -s #{wxh} #{Config.path('outbox')}/#{filename} 2>> #{Config.path('ffmpeg_log_file')}")
          $log.info "Done poster for #{video.name}"
          return true
        else
          $log.error video.fail_reason = "ffmpeg returned an error creating poster for #{video.name}"
          return false
        end
      end
      
      def gen_html(video)
        name = video.name
        size = video.maxed_size
        pub_url = Config.path('pub_url')
        
        begin
          erb = ERB.new File.new(File.dirname(__FILE__) + '/../../views/video.rhtml').read, nil, "%"
          File.open("#{Config.path('outbox')}/#{video.name}.html", 'w') do |f|
            f.write erb.result(binding)
          end
        rescue Exception => e
          $log.error video.fail_reason = "Unexpected error building HTML document for #{video.name}: #{e}"
          return false
        end
        
        $log.info "Built HTML document for #{video.name}"
        return true
      end
      
      def gen_job_report(job_id, videos, start_time, report_type)
        elapsed = "#{Time.now - start_time}s"
        
        begin
          erb = ERB.new File.new(File.dirname(__FILE__) + '/../../views/job-report.rhtml').read, nil, "%"
          File.open("#{Config.path('outbox')}/job-report-#{job_id}.html", 'w') do |f|
            f.write erb.result(binding)
          end
        rescue Exception => e
          $log.error "Unexpected error building job report: #{e}"
          return false
        end
        
        $log.debug "Built job report"
        return true
      end
      
      def publish(video)
        if system("scp #{Config.path('outbox')}/#{video.name}* #{Config['publish']['user']}@#{Config['publish']['server']}:#{Config['publish']['path']}/")
          $log.info "Published #{video.name} to #{Config['publish']['server']}"
          return true
        else
          $log.error video.fail_reason = "Error publishing #{video.name}"
          return false
        end
      end
      
      def archive(video)
        if system("scp #{video.path} #{Config['archive']['user']}@#{Config['archive']['server']}:#{Config['archive']['path']}/")
          $log.info "Archived #{video.name} source to #{Config['archive']['server']}"
          return true
        else
          $log.error video.fail_reason = "Error archiving #{video.name} source"
          return false
        end
      end
    end
  end
end