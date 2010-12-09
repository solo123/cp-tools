def clear_by_date
  cnt = 0
  Product.active.all.each do |p|
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
end

def format_name
  cnt = 0
  Product.all.each do |p|
    if p.name && p.name.length > 18
      p.name = "#{p.taxon_val('品牌')} #{p.property('型号')}"
      p.save!
      cnt += 1
      puts cnt.to_s + '. ' + p.name
    end
  end
end

def purge_product
  puts '...empty....(todo.)'
end

def available_by_quote
  cnt = 0
  Product.active.each do |p|
    cnt += 1
    pc = p.property('批发价')
    if pc
      pc = pc.to_d
      if pc<30
        p.available_on = nil
        p.save!
        puts "#{cnt}) #{p.name} : 错误价格下架"
      else
        if p.price != pc
          p.price = pc
          p.save!
          puts "#{cnt}) #{p.name} : 更新价格"
        end
      end
    else
      p.available_on = nil
      p.save!
      puts "#{cnt}) #{p.name} : 无价格下架"
    end

    ps = p.property('零售价')
    if ps
      ps = ps.to_d
      if ps > 8000
        ps = ps / 100
        pp = ProductProperty.find_by_product_id_and_property_id(p.id, p.properties.find_by_name('零售价').id)
        pp.value = ps.to_s
        pp.save!
        puts '修改零售价'
      end
    end
  end
end
def image_resize
  print 'Start id: '
  c = gets.chomp.to_i
  Product.active.all(:conditions => 'id>' + c.to_s, :order => 'id').each do |p|
    if p.images.length > 0
      p.images.first.attachment.reprocess!
      puts "#{p.id}) #{p.name}"
    end
  end
end

def update_brand_model
  print 'force update? (y/n)'
  not_force = (gets.chomp.upcase[0] == ?N)
  t = Taxonomy.find_by_name('品牌').id
  Product.not_deleted.each do |p|
    next if not_force && p.brand_id && p.model
    bnd = p.taxons.find_by_taxonomy_id(t)
    if bnd
      p.brand_id = bnd.id
    else
      p.brand_id = nil
      p.deleted_at = Time.now
    end
    p.model = p.property('型号')
    p.list_date = p.property('上市日期')
    p.save!
    puts "#{p.id}) #{p.name} - #{p.list_date}"
  end
end
def clear_dup
  p_id = 0
  b_id = 0
  md = nil
  Product.not_deleted.order(:brand_id, :model).each do |p|
    if (p.brand_id == b_id) && (p.model == md) && (p.id != p_id)
      p.deleted_at = Time.now
      p.save
      puts "delete:[#{p_id},#{p.id}] #{p.name}"
    else
      p_id = p.id
      b_id = p.brand_id
      md = p.model
    end
  end
end
def reset_model
  cnt = 0
  Product.where('deleted_at is not null').each do |p|
    brand = p.name.split(' ')[0]
    next if !brand || brand.length < 1
    t = Taxon.find_by_name(brand)
    next unless t
    p.brand_id = t.id
    p.deleted_at = nil
    p.save!
    cnt += 1
    puts "#{cnt}) #{p.name}"
  end
end

def reset_catalog
  Product.update_all('tax_category_id=1', 'tax_category_id is null')
  Product.update_all('shipping_category_id=1', 'shipping_category_id is null')
end

loop do
  print "0)quit 1)格式化产品名称, 2)按上市日期清理 3)清空产品回收站 4)无报价下架 5)Image resize\n" +
      "6)产品品牌型号 7)清理重复产品 8)reset model 9)设置价格类别"
  k = gets.chomp.upcase[0]
  if k == ?0
    break
  elsif k == ?1
    format_name
  elsif k == ?2
    clear_by_date
  elsif k == ?3
    purge_product
  elsif k == ?4
    available_by_quote
  elsif k == ?5
    image_resize
  elsif k == ?6
    update_brand_model
  elsif k == ?7
    clear_dup
  elsif k == ?8
    reset_model
  elsif k == ?9
    reset_catalog
  end
end