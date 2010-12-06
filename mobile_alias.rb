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

puts <<EOF
insert into model_alias
(product_id, brand_id, model)
select id, brand_id, model from products where products.deleted_at is null

delete from model_alias where model is null

select brand_id, model, count(*) as cnt
from model_alias
group by brand_id, model
order by brand_id, model
having cnt > 1

EOF

print "r)Product->alias"
k = gets.chomp.upcase[0]
if k == ?R
  reload_product
end

