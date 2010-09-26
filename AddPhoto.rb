class PhotoTools
  def initialize(path)
    if Dir[path].length > 0
      Dir.entries(path).each do |p|
        if !'..国内品牌，国际品牌'.include?(p)
          puts p
          return
        end
      end
      @path = path
      @count = 0
		@photo_count = 0
    end
    @debug = (__FILE__ == $0)
    @dbg = @debug ? '(test)' : '>>'
  end

  def do_process
    if !@path
      puts "Invalid path! Please retry. " 
      return
    end

    @product_tool = ProductHelper.new
    Dir.entries(@path).each do |cat|
      next if cat.match(/\./)
      @catalog = cat
      puts "CAT: #{@catalog}"

      @product_tool.set_parent_brand(cat) if !@debug
      Dir.entries(@path + '/' + cat).each do |brand|
        @brand = brand
        process_brand if !brand.match(/\./)
      end
    end

    puts '---DONE---'
  end

  def process_brand
    Dir.entries(@path + '/' + @catalog + '/' + @brand).each do |model|
      @model = model
      process_model if !model.match(/\./)
    end
  end

  def process_model
    p = @product_tool.find_or_create(@brand, @model) if !@debug
    Dir[@path + '/' + @catalog + '/' + @brand + '/' + @model + '/*.jpg'].each do |f|
		if !@debug
		   begin
		     img = Image.create(:attachment => File.open(f), :viewable => p)
		   rescue
		     puts "  Invalid image:" << f
		   end
	   end
		@photo_count = @photo_count + 1
      puts @dbg + @photo_count.to_s + "." + @brand + '/' + @model + " \t-- img:" + f
    end
  end
end
