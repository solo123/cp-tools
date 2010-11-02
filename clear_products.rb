cnt = 0
Product.active.price_between(0,20).each do |p|
  pp = p.property('上市日期')
  if !pp || pp < '2008'
    p.available_on = nil
    p.save!
    cnt += 1
    puts cnt
  else
    print '.'
  end

end