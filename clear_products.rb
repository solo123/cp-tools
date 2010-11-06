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

loop do
  print '0)quit 1)格式化产品名称, 2)按上市日期清理 3)清空产品回收站 4)无报价下架'
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
  end
end