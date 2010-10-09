i = 0
Product.all.each do |p|
  price = p.property('批发价')
  if price && price.to_d > 0 && p.price != price.to_d
    i = i + 1
    puts "#{i}. #{p.name} : #{price.to_d} => #{p.price}"
    p.price = price.to_d
    p.save
  end
end