cnt = 0
Product.all.each do |p|
  if p.name && p.name.length > 18
    p.name = "#{p.taxon_val('品牌')} #{p.property('型号')}"
    p.save!
    cnt += 1
    puts cnt.to_s + '. ' + p.name
  end
end