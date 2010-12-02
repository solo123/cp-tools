def reload_product
  puts "Refresh Product to alias"
  cnt =  0
  Product.not_deleted.each do |p|
    al = ModelAlia.where('brand_id=? and model=?', p.brand_id, p.model)
    if al.empty?
      ma = ModelAlia.new
      ma.product_id = p.id
      ma.brand_id = p.brand_id
      ma.model = p.model
      ma.save!
      cnt += 1
      puts "#{cnt}) #{p.name}"
    end
  end
end




print "r)Product->alias"
k = gets.chomp.upcase[0]
if k == ?R
  reload_product
end

