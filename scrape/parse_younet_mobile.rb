require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'


def parse_younet_mobile(url)
	doc = ( Hpricot(open(URI.escape(url))) rescue '' )
  return nil if doc == ''

  phone = {}
  phone[:title] = @conv.iconv(doc.search("div[@class='inner-header']/h1")[0].inner_text)
  phone[:model] = /(\w+)\s(.*)/.match(phone[:title])[2]

  phone[:props] = []
  paras = doc.search("div[@class='phone-parameter']/dl/dd")
  ptits = doc.search("div[@class='phone-parameter']/dl/dt")
  ptits.each_with_index do |tit, idx|
    t = (@conv.iconv(tit.inner_text) rescue '')
    v = (@conv.iconv(paras[idx].inner_text) rescue '')
    phone[:props] << [t, v]
  end

  fs = []
  doc.search('.function-icon/ul/li/a/img').each do |img|
    m = /\/(\d+).jpg$/.match(img['src'])
    fs << m[1] if m
  end
  phone[:functions] = fs.join(',')
  phone[:description] = (@conv.iconv(doc.search('.parameters-box')[0].inner_html) rescue '')
  phone
end