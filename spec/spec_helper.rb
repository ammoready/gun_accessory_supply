$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'pp'

require 'gun_accessory_supply'

# support files
root = File.expand_path('../..', __FILE__)
Dir[File.join(root, "spec/support/*.rb")].each { |f| require f }

RSpec.configure do |config|

  # configure options for dummy FTP connection
  config.before(:suite) do
    GunAccessorySupply.configure do |config|
      config.ftp_host      = "ftp.host.com"
      config.top_level_dir = "Test"
    end
  end

  config.include FixtureHelper
end
