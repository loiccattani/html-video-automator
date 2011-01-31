#!/usr/local/bin/ruby
# Title: Maxisize
# Author: Loïc Cattani "arko" <loic.cattani@gmail.com>
# Begin: 2011.01.31

# A small utility script that accept a width an height as first and
# second parameter and returns a maximized "wxh" value. Scaling down
# the size if needed and keeping its aspect ratio.
#
# Usage: maxisize.sh width height (./maxisize.rb 640 480 => "640x480")

# Config
max_width = 640
max_height = 480

width = ARGV[0].to_i
height = ARGV[1].to_i

aspect_ratio = width.to_f / height.to_f

# puts "Input: #{width.to_s}x#{height.to_s} (#{aspect_ratio})"

if width > max_width && aspect_ratio >= 1.0
  width = max_width
  height = [width/aspect_ratio, max_height].min.to_i
elsif height > max_height && aspect_ratio < 1.0
  height = max_height
  width = [height*aspect_ratio, max_width].min.to_i
end

puts "#{width.to_s}x#{height.to_s}"
