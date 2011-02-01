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

CONFIG = YAML.load_file('hva.config.yml')['development']
#CONFIG = YAML.load_file("/etc/hva.config.yml")['production']

# Logger
logger = Logger.new(File.expand_path(CONFIG['log_file']))
logger.level = Logger::DEBUG

logger.info "HTML Video Automator Started"

# Try to lock HVA execution (Only one instance of this script can run at a time)
begin
  FileUtils.mkdir '/tmp/hva-lock'
rescue Exception => e
  logger.error "HVA already running. Aborting..."
  abort("HVA already running. #{e}")
end



# Unlock
FileUtils.rmdir '/tmp/hva-lock'
