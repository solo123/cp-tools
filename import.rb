class ImportCSV
	def parse_product(line)
		p_price = line["批发价"]
		if !p_price
		   p_price="0"
		end
		p = Product.create \
			:name => line["名称"] ? line["名称"] : line["品牌"] + " " + line["型号"],
			:price => p_price.to_d,
			:description => line["详细信息"],
			:permalink => line["货号"] ? line["货号"] : "CP-" + Time.now.strftime("%y%m%d").to_i.to_s(35) + "-" + ("%04d" % line["序号"].to_i),
			:available_on => Time.now

		p.shipping_category = ShippingCategory.find_or_create_by_name("Type A")
		
		# 品牌，制式，分类
		find_or_create_taxonomy if !@taxonomy_id
		@the_taxons = []
		add_brand_taxon(line["品牌"])
		add_simple_taxon("制式", line["制式"])
		add_simple_taxon("分类", line["分类"])
		p.taxons = @the_taxons
		
		p_type = line["型号"]		
		p_type = line["名称"].to_s.strip[/[^a-zA-Z0-9]+([a-zA-Z0-9]+)/,1] if !p_type && line["名称"]

		prop = Property.find_or_create_by_name_and_presentation("型号", "型号")
		ProductProperty.create :property => prop, :product => p, :value => p_type if p_type
		
		s_field = "名称，品牌，型号，货号，详细信息，制式，上市时间，序号，样式，分类，颜色，图片"
		line.each do |c|
			next if s_field.include?(c[0])
			prop = Property.find_or_create_by_name_and_presentation(c[0],c[0])
			ProductProperty.create :property => prop, :product => p, :value => c[1]
  		end
  		
		pt = OptionType.find_or_create_by_name_and_presentation("颜色", "颜色")
		p.option_types << pt
		if line["颜色"]
  			line["颜色"].split(/\s*[\/,，、]\s*/).each do |p_color|
  				p_color << "色" if !p_color.include?("色")
  				ov = OptionValue.find_or_create_by_name_and_presentation_and_option_type_id(p_color,p_color, pt.id)
  				
  				v = Variant.create :product => p
  				v.option_values << ov
  			end
  		end
  		
  		if line["图片"]
  			imgs = line["图片"].split(',')
  			imgs.each do |img_name|
				#for image for product (all variants)
				begin
					img = Image.create(:attachment => File.open(@@start_path + 'images/' + img_name), :viewable => p)
				rescue
					puts "  Invalid image:" << img_name
				end
			end

			#for image for single variant
			#img = Image.create(:attachment => File.open(path), :viewable => variant)
		end

  		p.save
  		@count = 0 if !@count
  		@count = @count + 1
  		puts @count.to_s + " : " + p.name

	end
	
	def add_simple_taxon(taxonomy, taxon_text)
		if taxon_text
			c_id = Taxonomy.find_or_create_by_name(taxonomy).id
			p_id = Taxon.find_by_name(taxonomy).id
			names = taxon_text.split(/\s*[,，、]\s*/)
			names.each do |name|
				@the_taxons << Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(taxon_text, p_id, c_id)
			end
		end
	end
	def find_or_create_taxonomy
		@taxonomy_id = Taxonomy.find_or_create_by_name("品牌").id
		p_id = Taxon.find_by_name("品牌").id
		if @@base_catalog.length > 0
			@taxonomy_brand = Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(@@base_catalog, p_id, @taxonomy_id).id
		else
			@taxonomy_brand = p_id
		end
	end
	def add_brand_taxon(brand)
		@the_taxons << Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(brand, @taxonomy_brand, @taxonomy_id)
	end
end
