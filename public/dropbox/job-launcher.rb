#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../lib/html_video_automator'
require "cgi"

cgi = CGI.new
runner = HTMLVideoAutomator::Runner.new

if cgi.request_method == 'GET'
  runner.show_dropbox
elsif cgi.request_method == 'POST' and ! cgi.params['files'].empty?
  runner.launch_job(cgi.params['files'])
else
  $log.fatal "Unhandled method or missing parameters"
end
