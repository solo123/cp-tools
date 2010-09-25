Product.all.each do |p|
	if p.description
		p.description = p.description.gsub(/src="\/shop/, 'src="http://99buy.com.cn/shop')
		p.save
		puts p.name
	end 
end