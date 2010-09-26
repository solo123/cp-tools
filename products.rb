class ProductHelper
  def initialize
    @count = 1
  end

  def set_parent_brand(parent_brand)
    # lazy load, can't use: return if ! defined? Product
		@taxonomy_id = Taxonomy.find_or_create_by_name("品牌").id
		p_id = Taxon.find_by_name("品牌").id
    @taxonomy_brand = Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(parent_brand, p_id, @taxonomy_id).id
  end

  def find_or_create(brand, model)
    p = Product.in_taxon(brand).with_property_value("型号",model)
    return p[0] if p.count > 0

    p = Product.create \
			:name => brand + ' ' + model,
			:price => 1.0,
			:description => '',
			:permalink => "CP-" + Time.now.strftime("%y%m%d").to_i.to_s(35) + "-" + ("%04d" % @count.to_i),
			:available_on => Time.now


		p.shipping_category = ShippingCategory.find_by_name("Type A")

    the_taxons = []
		the_taxons << Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(brand, @taxonomy_brand, @taxonomy_id)
    p.taxons = the_taxons

		prop = Property.find_or_create_by_name_and_presentation('型号', '型号')
		ProductProperty.create :property => prop, :product => p, :value => model

 		p.save
 		@count = @count + 1
 		puts '  >>NEW: ' + @count.to_s + " : " + p.name
    p
  end

end
