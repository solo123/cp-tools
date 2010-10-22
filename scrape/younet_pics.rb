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
  puts @count.to_s + " Product: " + url

	doc = ( Hpricot(open(url)) rescue '' )
  title = @conv.iconv(doc.search("div[@class='inner-header']/h1")[0].inner_text)
  model = /(\w+)\s(.*)/.match(title)[2]

  pic = doc.search(".phone-img/img")[0].attributes['src']
  save_pic(brand, model, '0.jpg', pic)
end

def save_pic(brand, model, filename, url)
  create_path(brand, model)
  open(@base_dir + '/' + brand + '/' + model + '/' + filename,'wb').write(open(url).read)
end

def create_path(brand, model)
  @base_dir ||= Time.now.strftime('%Y%m%d')
  p = @base_dir
  Dir.mkdir(p) unless File.exist?(p)
  p = @base_dir + '/' + brand
  Dir.mkdir(p) unless File.exist?(p)
  p = @base_dir + '/' + brand + '/' + model
  Dir.mkdir(p) unless File.exist?(p)
end

$KCODE="u"
@conv = Iconv.new("UTF8//IGNORE","GBK")
@count = 0
parse_catalog('http://mobi.younet.com/')
#parse_brand('HTC', 'http://mobi.younet.com/htc')
#parse_mobile('HTC', 'http://mobile.younet.com/files/23/23650.html')
#parse_mobile('CECT', 'http://mobile.younet.com/files/13/13587.html')
