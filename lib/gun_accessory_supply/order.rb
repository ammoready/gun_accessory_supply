module GunAccessorySupply
  # To submit an order:
  #
  # * Instantiate a new Order, passing in `:username`
  # * Call {#add_recipient}
  # * Call {#add_item} for each item on the order
  #
  # See each method for a list of required options.
  class Order < Base

    # @option options [String] :username *required*
    def initialize(options={})
      requires!(options, :username, :po_number)

      @dealer_number = options[:username]
      @po_number     = options[:po_number]
      @items         = []
    end

    # @param header [Hash]
    #   * :dealer_name [String] *required*
    #   * :ffl [String]
    #   * :shipping [Hash] *required*
    #     * :name [String] *required*
    #     * :address [String] *required*
    #     * :city [String] *required*
    #     * :state [String] *required*
    #     * :zip [String] *required*
    #     * :email [String] *required*
    #     * :phone [String] *required*
    #   * :special_instructions [String] optional
    def add_recipient(hash={})
      requires!(hash, :dealer_name, :shipping)
      requires!(hash[:shipping], :name, :address, :city, :state, :zip, :email, :phone)
      @headers = hash
    end

    # @param item [Hash]
    #   * :identifier [String] *required*
    #   * :description [String]
    #   * :upc [String] *required*
    #   * :qty [Integer] *required*
    #   * :price [String]
    def add_item(item={})
      requires!(item, :identifier, :upc, :qty)
      @items << item
    end

    def filename
      return @filename if defined?(@filename)
      timestamp = Time.now.strftime('%Y%m%d%T').gsub(':', '')
      @filename = "GUN-ACCESSORY-SUPPLY-#{@po_number}-#{timestamp}.xml"
    end

    def submit!
      write_file("/in/#{filename}", self.to_xml)
    end

    def to_xml
      output = ""

      xml = Builder::XmlMarkup.new(target: output, indent: 2)

      xml.instruct!(:xml)

      xml.Request do
        xml.OrderRequest do
          xml.OrderRequestHeader(:orderDate => Time.now, :type => 'new') do
            xml.ShipTo do
              xml.Address do
                xml.Name "Test"
                xml.Email "Email"
                xml.PostalAddress do
                  xml.DeliverTo "Test Name"
                  xml.Street "1 Street"
                  xml.City "City"
                  xml.State "State"
                  xml.PostalCode "PostalCode"
                  xml.Country "Country"
                end
              end
            end
            xml.BillTo do
              xml.Address do
                xml.Name "Test"
                xml.Email "Email"
                xml.PostalAddress do
                  xml.DeliverTo "Test Name"
                  xml.Street "1 Street"
                  xml.City "City"
                  xml.State "State"
                  xml.PostalCode "PostalCode"
                  xml.Country "Country"
                end
              end
            end
          end
          xml.ItemOut(quantity: 1) do
            xml.ItemID do
              xml.SupplierPartID 'Supplier Part ID'
            end
            xml.ItemDetail do
              xml.UnitPrice do
                xml.Money(currency: 'USD') "$5.00"
              end
              xml.Description "Item description"
            end
          end
        end
      end

      output
    end

  end
end
