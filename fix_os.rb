Product.all.each do |p|
  pp ||= Property.find_by_name('操作系统')
  os = p.taxon_val('操作系统')
  unless os.empty?
    ProductProperty.create :property => pp, :product => p, :value => os
    puts "Product:#{p.name}, os:#{os}"
  end
end