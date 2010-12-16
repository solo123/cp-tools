require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sms_db'


def parse_mobile(inp)
  puts "\n>> Product: #{inp.brand}-#{inp.model}"

		doc = Nokogiri::HTML(open(inp.url), nil, 'GBK')
    ms = doc.css('#tblPicMore a')
    ms.each do |m|
      img_doc = Nokogiri::HTML(open( 'http://shouji.tenaa.com.cn/Mobile/' + m.attr('href')), nil, 'GBK')
      img = img_doc.css('#img_Big')
      if img
        img_url = URI.join(inp.url, img.attr('src').value)
        img_url = img_url.to_s
        save_pic(inp.brand, inp.model, File.basename(img_url), img_url )
      end
    end

end

def save_pic(brand, model, filename, url)
  create_path(brand, model)
  (open(@base_dir + '/' + brand + '/' + model + '/' + filename,'wb').write(open(url).read) rescue puts "ERROR> #{brand}/#{model}, #{url}" )
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

count = 0
InpPhone.where('status=0').each do |inp|
  count += 1
  puts "#{count}) #{inp.brand}-#{inp.model}, #{inp.url}"
  parse_mobile(inp)
end