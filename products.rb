class ProductHelper
  def initialize
    @count = 0
  end

  def find_or_create(brand, model)
    @count += 1
    p = Product.find_by_brand_and_model(brand, model)
    return p if p

    p = Product.create \
			:name => brand + ' ' + model,
			:price => 0,
			:description => '',
			:permalink => "CP-" + Time.now.strftime("%y%m%d").to_i.to_s(35) + "-" + ("%04d" % @count.to_i),
      :model => model


    @taxonomy_brand ||= Taxon.find_by_name('国内品牌')
    p.taxons << Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(brand, @taxonomy_brand.id, @taxonomy_brand.taxonomy_id)

		@prop ||= Property.find_by_name('型号')
		ProductProperty.create :property => @prop, :product => p, :value => model

 		p.save!
 		print ' >>NEW '
    p
  end

end
