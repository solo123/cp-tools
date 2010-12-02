class Mobile < ActiveRecord::Base
end

def update_properties(product, mobile)
  @props ||= [
    ['screen','屏幕'], ['color','颜色'], ['standard','标配'], ['os','操作系统'],
    ['market_price','零售价'], ['wholesale_price','批发价'],
    ['listing_date','上市日期'], ['frequency','频率'], ['size','尺寸'],
    ['cpu','CPU'], ['memory','内存'], ['talk_time','通话时长'], ['standby_time','待机时长']
  ]

  @props.each do |prop|
    if mobile[prop[0]] && !mobile[prop[0]].to_s.strip.empty?
      pp = Property.find_by_name(prop[1])
      pp ||= Property.create(:name => prop[1], :presentation => prop[1])
      pv = ProductProperty.find_by_product_id_and_property_id(product.id, pp.id)
      if pv
        pv.value = mobile[prop[0]]
        pv.save!
      else
        ProductProperty.create :property => pp, :product => product, :value => mobile[prop[0]]
      end
    end
  end
  product.description = mobile.description if mobile.description && !mobile.description.empty?
end

def update_taxons(product, mobile)
  mobile.system.strip.split('/').each    { |taxon| add_taxon(product, taxon, '制式') }    if mobile.system && !mobile.system.strip.empty?
  mobile.functions.strip.split(',').each { |taxon| add_taxon(product, taxon, '功能') }    if mobile.functions && !mobile.functions.strip.empty?
  mobile.style.strip.split(',').each     { |taxon| add_taxon(product, taxon, '样式') }    if mobile.style && !mobile.style.strip.empty?
end
def add_taxon(product, taxon_name, taxonomy_name)
  @parent_taxons ||= {}
  @parent_taxons[taxonomy_name] ||= taxon_find_or_create(taxonomy_name)
  t = Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(taxon_name, @parent_taxons[taxonomy_name].id, @parent_taxons[taxonomy_name].taxonomy_id)
  product.taxons << t unless product.taxons.find_by_id(t.id)
end
def taxon_find_or_create(taxon_name)
  t = Taxon.find_by_name(taxon_name)
  unless t
    tm = Taxonomy.find_or_create_by_name(taxon_name)
    pm = Taxon.find_by_name(taxon_name)
    t = Taxon.new(:name => taxon_name, :taxonomy_id => tm.id, :parent_id => pm.id)
  end  
  t
end


cnt = 0
Mobile.all(:conditions => 'status=0').each do |m|
  cnt = cnt + 1
  print cnt
  print " [#{m.id}]#{m.brand} #{m.model} => "
  p = find_or_create(m.brand, m.model)
  update_taxons(p, m)
  update_properties(p, m)
  p.save!

  m.status = 1
  m.save!
  
  puts p.name
end

