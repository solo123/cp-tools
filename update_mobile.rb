def do_update
  InpPhone.where('status=1 and product_id>0').each do |phone|
    p = Product.find(phone.product_id)
    p.property
  end
end

print "u)更新到产品库"
op = gets.chomp.upcase[0]
if op == ?U
  do_update
end

