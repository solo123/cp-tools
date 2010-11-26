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
class InpPhone < SmsDB
end
class InpPhoneProp < SmsDB
end

def parse_catalog(url)
	puts "CATALOG: " << url.to_s
	doc = (Hpricot(open(URI.encode('http://youa.baidu.com/search/' + url))) rescue nil)
	puts "[ERROR:notfound] " << url.to_s;	return unless doc

  count = 0
	doc.search(".hProduct").each do |row|
    count = count + 1
    parse_phone(row)
  end

  nextp = doc.search('a.global-page-next')
  if nextp && nextp.length > 0
    parse_catalog(nextp[0]['href'])
  end
end

def parse_phone(row)
  phone = InpPhone.new
  tit = row.search('.info/h3/a')

  phone.name = @conv.iconv tit.text
  phone.brand, phone.model = phone.name.split /\s/
  phone.model_1 = phone.name.split(/\s/)[1..100].join(' ')
  phone.url = tit[0]['href']
  phone.status = 0
  phone.save!

  row.search('.info li').each do |prow|
    pn = (@conv.iconv prow.inner_text).strip
    prop = InpPhoneProp.new
    prop.phone_id = phone.id
    prop.prop, prop.val = pn.split /[：:]/
    prop.status = 0
    prop.save! if prop.val
  end

  puts "name:[#{phone.name}] brand:[#{phone.brand}] model:[#{phone.model}] model_1:[#{phone.model_1}]"
end


$KCODE="u"
@conv = Iconv.new("UTF8//IGNORE","GBK")
@count = 0

printf 'Parse url: '
url = 's?search_domain=1&category=6232bfd15e40303d223945fb&is_used=0&display_mode=1&show_tab=1&start_pos=0'
parse_catalog(url)

#http://youa.baidu.com/search/s?search_domain=1&category=6232bfd15e40303d223945fb&is_used=0&display_mode=1&show_tab=1&prop_ex=|%C6%B7%C5%C6%2C%C5%B5%BB%F9%D1%C7|
#parse_brand('HTC', 'http://mobi.younet.com/htc')
#parse_mobile('HTC', 'http://mobile.younet.com/files/23/23650.html')
#parse_mobile('CECT', 'http://mobile.younet.com/files/13/13587.html')
