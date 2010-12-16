require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'

require 'sms_db'

def parse_main_catalog(url)
	puts "CATALOG: " << url.to_s
	doc = nil
	begin
		doc = Hpricot(open(URI.encode(url)))
	rescue
		puts "[ERROR:notfound] " << url.to_s
		return
	end
  clk = doc.search('#point')[0].attributes['onclick']
  pages = clk.split(',').last.match /\d+/
  pages = pages[0].to_i
  puts "Pages: #{pages}"
  (1..pages).each do |i|
    u = "http://shouji.tenaa.com.cn/JavaScript/MobileGoodsStation.aspx?DM=#{i}|tblGSM|24|#{pages}&type=04"
    parse_catalog(u)
  end
end
def parse_catalog(url)
	puts "CATALOG: " << url.to_s
	doc = nil
	begin
		doc = Hpricot(open(URI.encode(url)))
	rescue
		puts "[ERROR:notfound] " << url.to_s
		return
	end

	doc.search("table.lineGrayTD").each do |lists|
    as = lists.search('a')
    brand = @conv.iconv(as[1].inner_text)
    model = @conv.iconv(as[2].inner_text)
    url   = as[1].attributes['href']
    InpPhone.create(:brand => brand, :model => model, :url => "http://shouji.tenaa.com.cn/Mobile/" + url, :status => 0)
  end
end


$KCODE="u"
@conv = Iconv.new("UTF8//IGNORE","GBK")
@count = 0

uu = 'http://shouji.tenaa.com.cn/Mobile/MobileNew.aspx'
parse_main_catalog(uu)
