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
        row = parse_row(row)
        
        if i==0
          @headers = row
          next
        end

        category = row[@headers.index('Sub-Category')].try(:strip)

        item = {
          mfg_number:      row[@headers.index('Item ID')].try(:strip),
          upc:             row[@headers.index('UPC')].try(:strip),
          name:            row[@headers.index('Item Description')].try(:strip),
          quantity:        row[@headers.index("Available Qty")].to_i,
          price:           row[@headers.index('MSRP')].try(:strip),
          msrp:            row[@headers.index('MSRP')].try(:strip),
          map_price:       row[@headers.index('MAP Price')].try(:strip),
          brand:           row[@headers.index('Manufacturer')].try(:strip),
          item_identifier: row[@headers.index("Item ID")].try(:strip),
          category:        cleaned_category(category)[0],
          subcategory:     cleaned_category(category)[1],
          weight:          row[@headers.index('Shipping Weight')].try(:strip),
          features: {
            caliber:       row[@headers.index('Caliber')].try(:strip),
            image_name:    row[@headers.index("Image Link")].try(:strip),
          }
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

    private

    # Returns an array of ["Category", "Subcategory"]
    def cleaned_category(category_string)
      # ex. category_string = "Gun Care/Security/Safes"
      categories = category_string.split('/')

      category = case categories.first
      when 'Gun Care'
        if category_string.include?('Gun Care/Security')
          ["Accessories", "Security"]
        else
          ["Accessories", "Cleaning"]
        end
      when 'Hunting'
        if categories[1] == 'Knives'
          categories[2]
        else
          ["Hunting", "Accessories"]
        end
      when 'Miscellaneous'
        ["Accessories", "Miscellaneous"]
      when 'Outdoor'
        categories.last(2)
      when 'Parts'
        ["Accessories", "Gun Parts"]
      when 'Shooting'
        categories.last(2)
      end

      category.present? ? category : categories.first(2)
    end

  end
end
