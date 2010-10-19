i = 0
Product.all.each do |p|
  if p.taxon_val('品牌').empty?
    i = i + 1
    puts i.to_s + ' ' + p.name
    p.delete
  end
end