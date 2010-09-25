#simple 99buy scrape

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'faster_csv'

require '99buy-mobile.rb'

# Get a Nokogiri::HTML:Document for the page we’re interested in...
@count = 0

def parse_catalog(csv, url)
	puts "CATALOG: " << url.to_s
	doc = nil
	begin
		doc = Nokogiri::HTML(open(url))
	rescue
		puts "[ERROR:notfound] " << url.to_s
		return 
	end
	
	doc.css('.goodsItem').each do |goods|
		@count = @count + 1
		uu = URI.join(url.to_s.strip, goods.css('p a')[0]['href'].to_s.strip)
		parse_mobile(csv, uu)
	end
	
	next_page = doc.css('#pager .next')
	if next_page.length>0
		ss = next_page[0]['href'].to_s
		u = URI.join(url.to_s.strip, ss.strip)
		parse_catalog(csv, u)
	end
end

if ARGV.length==0
	puts "Usage: " << $0 << " [url]"
else
	FasterCSV.open("out.csv", "w") do |csv|
		ARGV.each do |url| 
			parse_catalog(csv, url)
		end
	end
end

