#simple 99buy scrape

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'faster_csv'

require '99buy-mobile.rb'


if ARGV.length==0
	puts "Usage: " << $0 << " [url]"
else
	csv = $stdout
	parse_mobile(csv, ARGV[0])
end

