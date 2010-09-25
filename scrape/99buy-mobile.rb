#simple 99buy scrape

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'

# Get a Nokogiri::HTML:Document for the page we’re interested in...
module Scrape
	class Product
		attr_accessor :name, :brand, :model, :system, 
		:color, :style, :screen, :standard, :salepoint, 
		:price_pub, :price_whole, :taxon, :pic_path,
		:description
	end 
end

def parse_mobile(csv, url)
	puts "  >" << @count.to_s << url.to_s

	doc = nil
	begin
		doc = Nokogiri::HTML(open(url))
	rescue
		puts "[ERROR:notfound] " << url
		return 
	end
	
	mobile = doc.css('#goodsInfo')[0]
	form = mobile.css('#ECS_FORMBUY')[0]
	p = Scrape::Product.new
	p.name = form.css('div')[0].content.strip
	dds = form.css('ul li dd')
	dds.each do |dd|
		if dd.content =~ /商品品牌/
			p.brand = dd.css('a')[0].content.strip
		elsif dd.content =~ /颜色/
			p.color = dd.css('label')[0].content.strip
		elsif dd.content =~ /商城售价/
			p.price_pub = dd.css('font')[0].content.match(/\d+(\.\d+)?/)[0]
		end
		qq = doc.css('#com_h blockquote')
		p.description = qq[0].inner_html.strip.gsub(/\n/,'')
		p.description = p.description.gsub(/src="\/shop/, 'src="http://99buy.com.cn/shop') if p.description
		p.standard = qq[1].inner_html.strip.gsub(/\n/,'')
	end

	p.pic_path = ""
   imgs = doc.css('#imglist a')
   imgs.each do |img|
   	img_name = img["href"].to_s[/(.*\/)(.*$)/, -1]
   	p.pic_path << img_name
   	p.pic_path << ','
   
		Net::HTTP.start("99buy.com.cn") { |http|
  			resp = http.get("/shop/" + img["href"])
  			open('images/' + img_name, "wb") { |file|
    			file.write(resp.body)
   		}
		}
	end
	
   csv << [
	    p.name,p.brand,p.model,
   	 p.price_pub,p.standard,p.pic_path,p.description
   ]
   


end


