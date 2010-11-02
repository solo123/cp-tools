cnt = 0
Product.active.price_between(0,20).each do |p|
  p.available_on = nil
  p.save!
  cnt += 1
  puts cnt
end