# Gun Accessory Supply

Ruby library for Gun Accessory Supply.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gun_accessory_supply'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gun_accessory_supply



#TODO: Update info below



## Usage

**Note:** Nearly all methods require `:username` and `:password` keys in the options hash.

```ruby
options = {
  username: 'dealer@example.com',
  password: 'sekret-passwd'
}
```

### GunAccessorySupply::Catalog

To get all items in the catalog:

```ruby
catalog = []
GunAccessorySupply::Catalog.new(options).all do |i|
  catalog << i
end
```

See `GunAccessorySupply::Catalog` for the response structure.

### GunAccessorySupply::Inventory

To get your inventory details (availability, price, etc.):

```ruby
inventory = []
GunAccessorySupply::Inventory.new(options).all do |i|
  inventory << i
end
```

See `GunAccessorySupply::Inventory` for the response structure.

### GunAccessorySupply::Category

Returns an array of category codes and descriptions.

```ruby
categories = GunAccessorySupply::Category.all(options)

# [
#   {:code=>"H648", :description=>"AIRGUNS"},
#   {:code=>"H610", :description=>"AMMUNITION"},
#   ...,
# ]
```

### GunAccessorySupply::Order

To build and submit an order, the basic steps are: 1) instantiate an Order object, 2) add header
information, 3) add item information (multiple items if needed), 4) submit the order.

```ruby
# Instantiate the Order instance, passing in your :username and :password
order = GunAccessorySupply::Order.new(options)

# Add header information:
header_opts = {
  customer: '...',  # customer number
  purchase_order: '...',  # application specific purchase order
  ffl: '...',  # your FFL number
  shipping: {  # shipping information (all fields except :address_2 are required)
    name: '...',
    address_1: '...',
    address_2: '...',
    city: '...',
    state: '...',
    zip: '...',
  },

  # Optional fields:
  shipping_method: '...',
  notes: '...',
}
order.add_header(header_opts)

# Add item information:
item_opts = {
  item_number: '...',  # GunAccessorySupply item number
  description: '...',
  quantity: 1,
  price: '123.45',  # Decimal formatted price, without currency sign
}
order.add_item(item_opts)  # Multiple items may be added, just call #add_item for each one.

# Submit the order (returns true on success, raises an exception on failure):
order.submit!
```

See `GunAccessorySupply::Order` for details on required options.

### GunAccessorySupply::Tracking

For fetching tracking data for individual order fulfillments.

```ruby
tracking_details = GunAccessorySupply::Tracking.fetch_data(options)

# [
#   {:po_number=>"12345", :carrier=>"UPS", :tracking_numbers=>['123456789']},
#   {:po_number=>"54321", :carrier=>"UPS", :tracking_numbers=>['987654321']},
#   ...,
# ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ammoready/gun_accessory_supply.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
