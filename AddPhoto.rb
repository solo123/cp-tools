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
    end
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

      @product_tool.set_parent_brand(cat)
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
    Dir[@path + '/' + @catalog + '/' + @brand + '/' + @model + '/*.jpg'].each do |f|
      #exit if (@count = @count + 1) > 10

      #lazy load, can't use: if ! defined? Product

      # import to spree!
      p = @product_tool.find_or_create(@brand, @model)
      begin
        img = Image.create(:attachment => File.open(f), :viewable => p)
      rescue
        puts "  Invalid image:" << f
      end
      puts " Add:" << @brand << '/' << @model << " -- img:" << f
    end
  end
end
