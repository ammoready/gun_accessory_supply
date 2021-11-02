module GunAccessorySupply
  # Category item response structure:
  #
  #   {
  #     code:        "...",  # ':category_code' in Catalog response.
  #     description: "..."   # ':category_description' in Catalog response.
  #   }
  class Category < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(&block)
    end

    # Returns an array of hashes with category details.
    def all(&block)
      categories = []

      # Categories are listed in catalog xml, so fetch that.
      catalog = Catalog.new(@options)
      catalog.all do |item|
        categories << {
          code: item[:subcategory].gsub("&amp;", "").gsub(/[^A-Za-z0-9]/, "_").squeeze("_").downcase,
          description: item[:subcategory].gsub("&amp;", "&")
        }
      end

      categories.uniq! { |c| c[:code] }
      categories.sort_by! { |c| c[:code] }

      categories.each do |category|
        yield category
      end
    end

  end
end
