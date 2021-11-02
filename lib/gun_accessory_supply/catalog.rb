module GunAccessorySupply
  class Catalog < Base
    
    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def all
      tempfile = get_most_recent_file(GunAccessorySupply.config.catalog_filename_prefix, GunAccessorySupply.config.top_level_dir)
      items = []

      File.open(tempfile).each_with_index do |row, i|
        row = row.split("\t")
        
        if i==0
          @headers = row
          next
        end

        if row[@headers.index('Category1')].try(:strip) == 'Guns'
          # Guns
          case row[@headers.index('Category2')].try(:strip)
          when 'Long Guns'
            @category    = row[@headers.index('Category3')].try(:strip)
            @subcategory = row[@headers.index("Category4")].try(:strip)
          when 'Handguns'
            @category    = row[@headers.index('Category2')].try(:strip)
            @subcategory = row[@headers.index("Category3")].try(:strip)
          end
        else
          # Everything else
          @category    = row[@headers.index('Category1')].try(:strip)
          @subcategory = row[@headers.index('Category2')].try(:strip)
        end

        item = {
          mfg_number:      row[@headers.index('Item ID')].try(:strip),
          upc:             row[@headers.index('Bar Code')].try(:strip),
          name:            row[@headers.index('Description')].try(:strip),
          quantity:        row[@headers.index('Qty available')].to_i,
          price:           row[@headers.index('Price')].try(:strip),
          brand:           row[@headers.index('Brand')].try(:strip),
          item_identifier: row[@headers.index("Item ID")].try(:strip),
          category:        @category,
          subcategory:     @subcategory,
          features:        {
                             image_name: row[@headers.index("ImageFileName\n")].try(:strip),
                           },
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

  end
end
