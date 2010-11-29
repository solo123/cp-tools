#!/usr/bin/ruby
require 'rubygems'
require 'fileutils'
require '../data/products.rb'

def process_model(path, brand, model)
  @pt ||= ProductHelper.new
  p = @pt.find_or_create(brand, model)
  Dir[path + '/' + brand + '/' + model + '/*.{jpg,png,gif}'].each do |f|
    begin
     Image.create(:attachment => File.open(f), :viewable => p)
     File.delete f
    rescue
     printf " (Invalid image:" << f << ")"
    end
  end
  ( FileUtils.rmdir path + '/' + brand + '/' + model  rescue print ' <rm error> ' )
end

if ARGV.length < 1
  puts "\nUsage: #{$0} PHOTO_PATH\n\n"
  exit
end

path = ARGV[0]
if Dir[path].length > 0
  Dir.entries(path).each do |p|
    print p
    print ', '
  end

  print "\n-------------\n导入以上品牌图片吗？ (Y/N) "
  r = STDIN.gets.chomp.upcase
  if r == 'Y'
    puts "\n---- 开始导入图片 ----"
    Dir.entries(path).each do |p|
      next if p[0] == ?.
      puts '>> ' + p + ':'

      Dir.entries(path + '/' + p).each do |m|
        next if m[0] == ?.
        puts '   - ' + m
        process_model(path, p, m)
      end
      ( FileUtils.rmdir path + '/' + p rescue print ' (rm error) ' )
    end
  puts "\n---- END ----"
  end
else
  puts "目录不存在！"
end
