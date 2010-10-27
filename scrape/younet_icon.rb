require 'rubygems'
require 'open-uri'

(1..80).each do |i|
  puts i
  ( open("icon/#{i}.jpg",'wb').write(open("http://mobile.younet.com/icon/#{i}.jpg").read) rescue 0 )
end


