require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'

require 'active_record'

class SmsDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
   :adapter  => "mysql",
   :database => "coolpur_sms",
   :encoding => "utf8",
   :username => "root",
   :password => 'liangyihua',
   :host     => 'localhost'
  )
end
class Mobile < SmsDB
end
class MobileProp < SmsDB
end

def parse_catalog(url)
	puts "CATALOG: " << url.to_s
	doc = nil
	begin
		doc = Hpricot(open(url))
	rescue
		puts "[ERROR:notfound] " << url.to_s
		return
	end

  count = 0
	doc.search("div[@class='brand-all-list']/ul").each do |lists|
    count = count + 1
    lists.search('a').each do |brand|
      b_name = @conv.iconv(brand.inner_text)
      b_url = brand.attributes['href']
      puts "Brand:#{b_name}, URL:#{b_url}"
      parse_brand(b_name, b_url)
    end
  end
end

def parse_brand(brand, url)
	puts "Brand: " << brand
	doc = nil
	begin
		doc = Hpricot(open(url))
	rescue
		puts "[ERROR:notfound] " << url.to_s
		return
	end

  cnt = 0
  doc.search("span[@class='ip-pn']/a").each do |p|
    p_name = @conv.iconv(p.inner_text)
    p_url = p.attributes['href']
    puts ">> Product: #{p_name}, URL:#{p_url}"
    parse_mobile(brand, p_url)
    cnt = cnt + 1
    #break if cnt > 2
  end
end

def parse_mobile(brand, url)
  @count = @count + 1

  puts "Product: " << url

	doc = nil
	begin
		doc = Hpricot(open(url))
	rescue
		puts "[ERROR:notfound] " << url.to_s
		return
	end


  title = @conv.iconv(doc.search("div[@class='inner-header']/h1")[0].inner_text)
  model = /(\w+)\s(.*)/.match(title)[2]
  paras = doc.search("div[@class='phone-parameter']/dl/dd")
  ptits = doc.search("div[@class='phone-parameter']/dl/dt")

  mobile = Mobile.find_by_brand_and_model(brand, model)
  mobile ||= Mobile.new

  mobile.brand = brand
  mobile.model = model

  mobile.screen = ''

  ptits.each_with_index do |tit, idx|
    t = (@conv.iconv(tit.inner_text) rescue '')
    v = (@conv.iconv(paras[idx].inner_text) rescue '')
    if t == '上市时间：'
      mobile.listing_date = v
    elsif t == '网络制式：'
      mobile.system = v
    elsif t == '适用频率：'
      mobile.frequency = v
    elsif t == '尺寸/体积：'
      mobile.size = v
    elsif t == '外观样式：'
      mobile.style = v
    elsif t == '可选颜色：'
      mobile.color = v
    elsif t == '屏幕参数：'
      mobile.screen = v
    elsif t == '操作系统：'
      mobile.os = v
    elsif t == '处理器：'
      mobile.cpu = v
    elsif t == '内存容量：'
      mobile.memory = v
    elsif t == '通话时间：'
      mobile.talk_time = v
    elsif t == '待机时间：'
      mobile.standby_time = v
    elsif t == '参考报价:'
      mobile.market_price = (paras[idx].search("span/a")[0].inner_text.to_f * 100).to_i
    elsif t == '标准配置:'
      mobile.standard = v
    elsif t == '内屏参数：'
      mobile.screen = mobile.screen + ' 内屏:' + v
    elsif t == '外屏参数：'
      mobile.screen = mobile.screen + ' 外屏屏:' + v
    elsif t == '重　量　：'
      0
    else
      puts " [MISS:#{brand}/#{model}] dt:#{t} dd:#{v}"
    end
  end

  fs = []
  doc.search("div[@class='function-icon']/ul/li/a").each do |fn|
    t = @conv.iconv(fn.attributes['rel'])
    pos = t.index("：")
    t = t[3..pos-1]
    fs << t
  end
  mobile.functions = fs.join(',')
  mobile.description = doc.search('.parameters-box')[0].inner_html
  mobile.salepoint = ''
  mobile.para = ''
  mobile.wholesale_price = ''
  mobile.taxon = ''

  mobile.save!
  puts @count.to_s + ') [' + mobile.id.to_s + '] - ' + brand + ', ' + model
end

$KCODE="u"
@conv = Iconv.new("UTF8//IGNORE","GBK")
@count = 0
parse_catalog('http://mobi.younet.com/')
#parse_brand('HTC', 'http://mobi.younet.com/htc')
#parse_mobile('HTC', 'http://mobile.younet.com/files/23/23650.html')
#parse_mobile('CECT', 'http://mobile.younet.com/files/13/13587.html')
