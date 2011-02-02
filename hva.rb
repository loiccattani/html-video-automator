#!/usr/bin/env ruby
# Title: HVA - HTML Video Automator
# Author: Loïc Cattani "Arko" <loic.cattani@gmail.com>
# Begin: 2011.01.28
#
# Ce script automatise l'encodage et la préparation du code HTML pour
# une ou plusieurs vidéos déposées dans une boîte de dépôt.
#
# Il est prévu pour être executé automatiquement par launchd lorsque
# la boîte de dépôt est modifiée.

require 'yaml'
require 'logger'
require 'fileutils'
require "erb"

class HTMLVideoAutomator
  def initialize
    @config = YAML.load_file('hva.config.yml')['global'] 
    @config.merge! YAML.load_file('hva.config.yml')['development']
    #@config.merge! YAML.load_file("/etc/hva.config.yml")['production']

    @log = Logger.new(@config['log_file'], 'daily')
    @log.level = Logger::INFO
  end

  def run

    @log.info "HTML Video Automator Started"

    # lock # Try mutex lock or abort

    @files = load_launchpad # Get all files on the launchpad

    @files.each do |file|
      @log.info "Processing #{file}"
      name = filename(file) # Get the file name, without extension
      size = get_size(file) # Get video size
      wxh = maxisize(size) # Get video size
      
      #next if ! encode file, :format => 'mp4', :size => wxh
      #next if ! encode file, :format => 'webm', :size => wxh
      #next if ! gen_poster file, :size => wxh
      next if ! gen_html name, :pub_url => @config['pub_url'], :size => size
      
      # TODO:
      # scp encoded movies and html doc to www server
      # scp source movies to archive server
      # Clean local files
    end

    # unlock # Unlock mutex

    @log.info "No more work! Will take a nap..."

  end
  
  private
  
  def load_launchpad
    # TODO: May need to filter input here...
    # but for now let's go with all files, ffmpeg's hungry.
    path = @config['launchpad']
    files = Dir.glob("#{path}/*")
    @log.info "#{files.count} files found on the launchpad"
    return files
  end
  
  def filename(file)
    basename = File.basename(file)
    name = basename[/(.*)\..*/,1] # Isolate filename from extension
  end
  
  def get_size(file)
    ffmpeg_out = `ffmpeg -i #{file} 2>&1` # ffmpeg outputs to stderr!
    width = ffmpeg_out[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 1].to_i
    height = ffmpeg_out[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 2].to_i
    return :width => width, :height => height
  end
  
  def maxisize(size)
    # Maxisize: Accept a size hash (:width, :height) and returns a
    # maximized "wxh" value. Scaling down the size only if needed and
    # keeping its aspect ratio.
    
    w = size[:width]
    h = size[:height]
    mw = @config['max_width']
    mh = @config['max_height']
    r = aspect_ratio(w, h)
  
    @log.debug "Original size: #{w}x#{h} (#{r.round(2)})"

    if w > mw && r >= 1.0
      w = mw
      h = [w / r, mh].min.to_i
    elsif h > mh && r < 1.0
      h = mh
      w = [h * r, mw].min.to_i
    end

    r = aspect_ratio(w, h)
    
    @log.debug "Maxed size: #{w}x#{h} (#{r.round(2)})"

    return "#{w}x#{h}"

  end
  
  def encode(file, params)
    name = filename(file) # Get the file name, without extension
    start_time = Time.now
    
    case params[:format]
    when 'mp4'
      outfile = "#{name}.mp4"
      status = system("ffmpeg -y -i #{file} -threads 0 -f mp4 -vcodec libx264 -vpre slow -vpre ipod640 -b 1200k -acodec libfaac -ab 160000 -ac 2 -s #{params[:size]} #{@config['payload']}/#{outfile} 2>> #{@config['ffmpeg_log_file']}")
    when 'webm'
      outfile = "#{name}.webm"
      status = system("ffmpeg -y -i #{file} -threads 0 -f webm -vcodec libvpx -g 120 -level 216 -qmax 50 -qmin 10 -rc_buf_aggressivity 0.95 -b 1200k -acodec libvorbis -aq 80 -ac 2 -s #{params[:size]} #{@config['payload']}/#{outfile} 2>> #{@config['ffmpeg_log_file']}")
    end
    
    if ! status
      @log.error "ffmpeg returned an error encoding #{outfile}"
      return false
    else
      @log.info "Done encoding #{outfile}. Elapsed #{(Time.now - start_time).to_i}s"
      return true
    end
  end
  
  def gen_poster(file, params)
    name = filename(file) # Get the file name, without extension
    outfile = "#{name}.jpg"
    
    status = system("ffmpeg -i #{file} -r 1 -ss 00:00:15.00 -vcodec mjpeg -vframes 1 -f image2 -s #{params[:size]} #{@config['payload']}/#{outfile} 2>> #{@config['ffmpeg_log_file']}")
    
    if ! status
      @log.error "ffmpeg returned an error creating poster for #{name}"
      return false
    else
      @log.info "Poster done for #{name}"
      return true
    end
  end
  
  def gen_html(name, params)
    pub_url = params[:pub_url]
    size = params[:size]
    
    erb = ERB.new File.new("views/video.rhtml").read, nil, "%"
    
    File.open("#{@config['payload']}/#{name}.html", 'w') do |f|
      f.write erb.result(binding)
    end
    
    @log.info "Built HTML document for #{name}"
  end
  
  def aspect_ratio(width, height)
    return width.to_f / height.to_f
  end
  
  def lock
    # Try to lock HVA execution
    # (Only one instance of this script can run at a time)
    begin
      FileUtils.mkdir '/tmp/hva-lock'
    rescue Exception => e
      @log.error "HVA already running. Aborting..."
      abort("HVA already running. #{e}")
    end
    @log.debug "Successfully locked mutex"
  end
  
  def unlock
    FileUtils.rmdir '/tmp/hva-lock'
    @log.debug "Unlocked mutex"
  end
  
end

hva = HTMLVideoAutomator.new
hva.run
