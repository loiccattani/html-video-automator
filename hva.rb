#!/usr/bin/env ruby
# Title: HVA - HTML Video Automator
# Author: Loïc Cattani "arko" <loic.cattani@gmail.com>
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

class HTMLVideoAutomator
  def initialize
    @config = YAML.load_file('hva.config.yml')['global'] 
    @config.merge! YAML.load_file('hva.config.yml')['development']
    #@config.merge! YAML.load_file("/etc/hva.config.yml")['production']

    @log = Logger.new(File.expand_path(@config['log_file']))
    @log.level = Logger::DEBUG
  end

  def run

    @log.info "HTML Video Automator Started"

    # lock # Try mutex lock or abort

    @files = load_launchpad # Get all files on the launchpad

    @files.each do |file|
      @log.info "Processing #{file}"
      name = filename(file) # Get the file name, without extension
      size = export_size(file) # Get video size

      # TODO:
      # Encode mp4
      # Encode webm
      # Gen poster
      # Build HTML document
      # scp encoded movies and html doc to www server
      # scp source movies to archive server
      # Clean local files
    end

    # unlock # Unlock mutex

  end
  
  private
  
  def load_launchpad
    # TODO: May need to filter input here...
    # but for now let's go with all files, ffmpeg's hungry.
    path = File.expand_path(@config['launchpad'])
    files = Dir.glob("#{path}/*")
    @log.info "#{files.count} files found on the launchpad"
    return files
  end
  
  def filename(file)
    basename = File.basename(file)
    name = basename[/(.*)\..*/,1] # Isolate filename from extension
  end
  
  def export_size(file)
    ffmpeg_out = `ffmpeg -i #{file} 2>&1` # ffmpeg outputs to stderr!
    width = ffmpeg_out[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 1].to_i
    height = ffmpeg_out[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 2].to_i
    return maxisize :width => width, :height => height
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
