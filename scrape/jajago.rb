#encoding: utf-8
class JajagoDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
   :adapter  => "mysql2",
   :database => "jajago",
   :encoding => "GBK",
   :username => "root",
   :password => 'liang',
   :host     => 'localhost'
  )
end
class EcsGood < JajagoDB
	self.primary_key = "goods_id"
end
class EcsGoodsAttr < JajagoDB
	set_table_name "ecs_goods_attr"
	self.primary_key = "goods_attr_id"
end

def find_or_create(brand_name, model)
  @taxonomy_id ||= Taxonomy.find_by_name('品牌').id
  brand = Taxon.find_by_name_and_taxonomy_id(brand_name, @taxonomy_id)
  unless brand
    @brand_china ||= Taxon.find_by_name('国内品牌').id

    brand = Taxon.new(:name => brand_name, :taxonomy_id => @taxonomy_id, :parent_id => @brand_china)
    brand.save!
  end
  
  product = nil
  ps = Product.in_taxon(brand).find_all_by_model(model)
  if ps.length > 0
    product = Product.find_by_id(ps[0].id)
  else
    product = Product.create \
			:name => brand_name + " " + model,
			:model => model,
			:price => 0,
			:description => '',
			:available_on => Time.now,
			:tax_category_id => 1

	product.taxons << brand
    @prop_model ||= Property.find_by_name("型号", "型号")
	ProductProperty.create :property => @prop_model, :product => product, :value => model
  end
  product
end
def get_goods_attr(goods_id, attr_id)
	attr = EcsGoodsAttr.find_by_goods_id_and_attr_id(goods_id, attr_id)
	return attr.attr_value if attr
	''
end
def add_goods_attr(product, prop_name, goods_id, attr_id)
	attr = EcsGoodsAttr.find_by_goods_id_and_attr_id(goods_id, attr_id)
	product.property(prop_name, attr.attr_value) if attr && attr.attr_value && !attr.attr_value.blank?
end
def scan_goods(ecs_last_update)
	name_mt = /^(\s*)([\u2E80-\u9FFF]+)(.+)/
	EcsGood.where("is_on_sale=1 and last_update>#{ecs_last_update}").each do |goods|
		s = goods.goods_name
		mt = name_mt.match(s)
		if mt
			puts "ID:#{goods.id} name:#{s}"
			brand = mt[2]
			model = mt[3]
			brand = brand.strip if brand
			model = model.strip if model
			p = find_or_create(brand, model)
			p.name = goods.goods_name
			p.description = goods.goods_desc
			p.meta_keywords = goods.keywords
			p.price = goods.market_price
			p.property('批发价', (goods.market_price + 5).to_s)
			p.property('零售价', goods.shop_price.to_s)
			p.property('市场价', goods.shopout_price.to_s)
			p.property('卖点', goods.goods_brief)
			add_goods_attr(p, '标配', goods.id, 268)
			p.add_taxon('制式', get_goods_attr(goods.id, 270))
			add_goods_attr(p, '上市日期', goods.id, 269)
			p.list_date = get_goods_attr(goods.id, 269)
			add_goods_attr(p, '屏幕', goods.id, 201)
			add_goods_attr(p, '颜色', goods.id, 342)
			add_goods_attr(p, '尺寸', goods.id, 280)
			add_goods_attr(p, '内存', goods.id, 324)
			add_goods_attr(p, '通话时长', goods.id, 337)
			add_goods_attr(p, '待机时长', goods.id, 338)
			add_goods_attr(p, '频率', goods.id, 271)
			add_goods_attr(p, 'CPU', goods.id, 304)
			add_goods_attr(p, '操作系统', goods.id, 303)
			add_goods_attr(p, '参数', goods.id, 335)
			begin
				p.name = p.id if p.name.blank?
				p.save
			rescue
				puts ">> save error in id:#{p.id}, name:#{p.name}"
			end
			#puts "image:#{goods.original_img}"
		end
	end
end

@conv = Iconv.new("utf-8//ignore", "gbk")
ecs_last_update = Spree::Config[:ecs_last_update]
ecs_last_update = 0 if !ecs_last_update
Spree::Config.set(:ecs_last_update => Time.now.to_i)
scan_goods(ecs_last_update)
