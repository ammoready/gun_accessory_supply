module GunAccessorySupply
  class Inventory < Base
    
    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def self.quantity(options = {})
      requires!(options, :username, :password)
      new(options).quantity
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

        item = {
          item_identifier: row[@headers.index('Item ID')].strip,
          quantity:        row[@headers.index('Qty available')].to_i,
          price:           row[@headers.index('Price')].strip,
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

    def quantity
      tempfile = get_most_recent_file(GunAccessorySupply.config.catalog_filename_prefix, GunAccessorySupply.config.top_level_dir)
      items = []

      File.open(tempfile).each_with_index do |row, i|
        row = row.split("\t")
        
        if i==0
          @headers = row
          next
        end

        item = {
          item_identifier: row[@headers.index('Item ID')].strip,
          quantity:        row[@headers.index('Qty available')].to_i,
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

  end
end
