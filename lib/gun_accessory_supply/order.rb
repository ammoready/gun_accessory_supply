module GunAccessorySupply
  # To submit an order:
  #
  # * Instantiate a new Order, passing in `:username`
  # * Call {#add_recipient}
  # * Call {#add_item} for each item on the order
  #
  # See each method for a list of required options.
  class Order < Base

    HEADERS = [
      'Ordering Dealer Number',
      'Ordering Dealer Name',
      'Ship to Name',
      'Ship To Address',
      'Ship to City',
      'Ship to State',
      'Ship to Zip',
      'Ship to email',
      'Ship to phone',
      'Ship to FFL',
      'Item',
      'Item Desc',
      'Item UPC',
      'Item Qty',
      'Item Price',
      'Special Instructions'
    ]

    # @option options [String] :username *required*
    def initialize(options = {})
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
    def add_recipient(hash = {})
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
    def add_item(item = {})
      requires!(item, :identifier, :upc, :qty)
      @items << item
    end

    def filename
      return @filename if defined?(@filename)
      timestamp = Time.now.strftime('%Y%m%d%T').gsub(':', '')
      @filename = "GUN-ACCESSORY-SUPPLY-#{@po_number}-#{timestamp}.csv"
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << HEADERS

        @items.each do |item|
          csv << [
            @dealer_number,
            @headers[:dealer_name],
            @headers[:shipping][:name],
            @headers[:shipping][:address],
            @headers[:shipping][:city],
            @headers[:shipping][:state],
            @headers[:shipping][:zip],
            @headers[:shipping][:email],
            @headers[:shipping][:phone],
            @headers[:ffl],
            item[:identifier],
            item[:description],
            item[:upc],
            item[:qty],
            item[:price],
            @headers[:special_instructions]
          ]
        end
      end # CSV.generate
    end

  end
end
