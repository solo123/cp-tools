require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'iconv'
require 'sms_db'

def parse_mobile(inp)
  puts "\n>> Product: #{inp.brand}-#{inp.model}"

	doc = nil
	begin
		doc = Nokogiri::HTML(open(inp.url), nil, 'GBK')
	rescue
		puts "[ERROR:notfound] " << inp.url.to_s
		return
	end

  doc.css('table#tblParameter tr').each do |list|
    dts = list.css('td')
    InpPhoneProp.create(:inp_phone_id => inp.id, :prop => dts[0].text, :val => dts[1].text, :status => 0)
    puts "#{dts[0].text} ==> #{dts[1].text}"
  end
  ms = doc.css('#tblMsg').text.split(' ')
  ms.each do |ss|
    next unless ss
    cs = ss.split('：')
    if cs && cs.length == 2
      InpPhoneProp.create(:inp_phone_id => inp.id, :prop => cs[0], :val => cs[1], :status => 0)
      puts ".. #{cs[0]} ==> #{cs[1]}"
    end
  end
end

count = 0
InpPhone.where('status=0').each do |inp|
  count += 1
  puts "#{count}) #{inp.brand}-#{inp.model}, #{inp.url}"
  parse_mobile(inp)
end
