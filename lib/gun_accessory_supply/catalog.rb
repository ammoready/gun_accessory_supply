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

        item = {
          mfg_number:      row[@headers.index('Item ID')].try(:strip),
          upc:             row[@headers.index('UPC')].try(:strip),
          name:            row[@headers.index('Item Description')].try(:strip),
          quantity:        row[@headers.index("Available Qty")].to_i,
          price:           row[@headers.index('MSRP')].try(:strip), # FIXME: Ensure this is the correct value
          brand:           row[@headers.index('Manufacturer')].try(:strip),
          item_identifier: row[@headers.index("Image Link")].try(:strip),
          category:        row[@headers.index('Category')].try(:strip),
          subcategory:     row[@headers.index('Category')].try(:strip), # FIXME: Need a sub-cat
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

  end
end
