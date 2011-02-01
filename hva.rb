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

class HTMLVideoAutomator
  
  require 'yaml'
  require 'logger'
  require 'fileutils'

  GLOBAL_CONFIG = YAML.load_file('hva.config.yml')['global']
  CONFIG = YAML.load_file('hva.config.yml')['development']
  #CONFIG = YAML.load_file("/etc/hva.config.yml")['production']
  
  # Log
  Log = Logger.new(File.expand_path(CONFIG['log_file']))
  Log.level = Logger::DEBUG

  def main

    Log.info "HTML Video Automator Started"

    # Try to lock HVA execution
    # (Only one instance of this script can run at a time)
    begin
      FileUtils.mkdir '/tmp/hva-lock'
    rescue Exception => e
      Log.error "HVA already running. Aborting..."
      abort("HVA already running. #{e}")
    end

    # Get all files on the launchpad
    # TODO: May need to filter input here...
    # but for now let's go with all files, ffmpeg's hungry.
    path = File.expand_path(CONFIG['launchpad'])
    files = Dir.glob("#{path}/*")

    Log.info "#{files.count} files found on the launchpad"

    files.each do |file|

      Log.info "Processing #{file}"

      # Get the file name, without extension
      basename = File.basename(file)
      name = basename[/(.*)\..*/,1]

      # Get video size
      ffmpeg_out = `ffmpeg -i #{file} 2>&1` # ffmpeg outputs to stderr!
      width = ffmpeg_out[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 1].to_i
      height = ffmpeg_out[/Video.*\s([0-9]{2,4})x([0-9]{2,4})/, 2].to_i
            
      # Get maxed size
      maxed_size = maxisize(width, height)

    end

    # Unlock
    FileUtils.rmdir '/tmp/hva-lock'

  end

  # Maxisize: Accept a width an height as first and second parameter
  # and returns a maximized "wxh" value. Scaling down the size if
  # needed and keeping its aspect ratio.
  def maxisize(width, height)

    max_width = GLOBAL_CONFIG['max_width']
    max_height = GLOBAL_CONFIG['max_height']
    
    aspect_ratio = width.to_f / height.to_f
    
    Log.debug "maxisize input: #{width.to_s}x#{height.to_s} (#{aspect_ratio})"

    if width > max_width && aspect_ratio >= 1.0
      width = max_width
      height = [width/aspect_ratio, max_height].min.to_i
    elsif height > max_height && aspect_ratio < 1.0
      height = max_height
      width = [height*aspect_ratio, max_width].min.to_i
    end

    aspect_ratio = width.to_f / height.to_f
    Log.debug "maxisize output: #{width.to_s}x#{height.to_s} (#{aspect_ratio})"

    return "#{width.to_s}x#{height.to_s}"

  end
  
end

HTMLVideoAutomator.new.main
