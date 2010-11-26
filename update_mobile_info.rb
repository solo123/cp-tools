require 'rubygems'
require 'open-uri'
require 'iconv'
require 'active_record'

class SmsDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
   :adapter  => "mysql2",
   :database => "coolpur_sms",
   :encoding => "utf8",
   :username => "root",
   :password => 'liangyihua',
   :host     => 'localhost'
  )
end
class Phone < SmsDB
end
class PhoneProp < SmsDB
end

def load_init_data
  Phone.delete_all
  PhoneProp.delete_all

  cnt = 0
  Product.not_deleted.each do |p|
    unless p.list_date
      cnt += 1
      if p.brand_id
        phone = Phone.new
        phone.product_id = p.id
        phone.brand = Taxon.find(p.brand_id).name
        phone.model = p.model
        phone.status = 0
        phone.save!
        puts "#{cnt}) #{phone.brand} - #{phone.model}"
      else
        puts "#{cnt}:#{p.id}) >> #{p.name}"
      end
    end
  end
end

def parse_younet
  require 'scrape/parse_younet_mobile'
  Phone.where('status=0').each do |p|
    get_phone_info(p)
  end
  puts "------------"
  Phone.where('status=10').each do |phone|
    next unless phone.url
    p = parse_younet_mobile(phone.url)
    save_mobile(phone, phone.url, p)
    phone.save!
  end
end

def get_phone_info(phone)
  name = "#{phone.brand} #{phone.model}"
	doc = ( Hpricot(open(URI.escape('http://user.younet.com/search/?search_phone=' + name))) rescue '' )
  if doc == ''
    phone.status = 7
    phone.save!
    return
  end
  lnk = doc.search('.result-list/dl/dt/a')
  if lnk && lnk.length > 0
    p = parse_younet_mobile(lnk[0]['href'])
    save_mobile(phone, lnk[0]['href'], p)
  else
    phone.status = 7 # error
  end
  phone.save!
end
def save_mobile(phone, url, p)
  phone.url = url
  if p
    phone.name = p[:title]
    phone.description = p[:description]
    PhoneProp.delete_all("phone_id=#{phone.id}")
    p[:props].each do |prop|
      pp = PhoneProp.new
      pp.phone_id = phone.id
      pp.prop = prop[0]
      pp.val = prop[1]
      pp.status = 0
      pp.save!
    end
    phone.model_1 = p[:model]
    phone.status = 1
    puts "#{phone.id}) #{phone.brand} - #{phone.model}"
  else
    phone.status = 6 # miss prop
  end
end


def check_dup
  Phone.where('status>0 and status<10').each do |p|
    if p.name && !( p.name.start_with? p.brand)
      p.status = 7
      p.save!
      puts "#{p.id}) #{p.name} - #{p.brand}"
    end
  end
end

$KCODE="u"
@conv = Iconv.new("UTF8//IGNORE","GBK")

print "(L)读取待处理数据 (P)抓取网站资料 (C)检查数据"
op = gets.chomp.upcase[0]
if op == ?L
  load_init_data
elsif op == ?P
  parse_younet
elsif op == ?C
  check_dup
end

#http://shouji.tenaa.com.cn/JavaScript/WebStation.aspx?DM=%E9%87%91%E7%AB%8B&type=31&SCQY=V6800;
#http://sh


#http://bible.younet.com/pagelist.php?trade=3&BoardID=307
