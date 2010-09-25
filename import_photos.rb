#!/usr/bin/ruby
require '../data/AddPhoto.rb'
require '../data/products.rb'

if ARGV.length < 1
  puts "\nUsage: #{$0} PHOTO_PATH\n\n"
  exit
end

pt = PhotoTools.new(ARGV[0])
pt.do_process