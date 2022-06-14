require 'gun_accessory_supply/version'

require 'csv'
require 'net/sftp'
require 'tempfile'

require 'active_support/all'

require 'gun_accessory_supply/base'
require 'gun_accessory_supply/catalog'
require 'gun_accessory_supply/category'
require 'gun_accessory_supply/inventory'
require 'gun_accessory_supply/order'
require 'gun_accessory_supply/tracking'
require 'gun_accessory_supply/user'

module GunAccessorySupply
  class InvalidOrder < StandardError; end
  class NotAuthenticated < StandardError; end
  class FileOrDirectoryNotFound < StandardError; end

  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor :debug_mode
    attr_accessor :ftp_host
    attr_accessor :ftp_port
    attr_accessor :top_level_dir
    attr_accessor :catalog_filename_prefix

    def initialize
      @debug_mode    ||= false
      @ftp_host      ||= "50.233.131.250"
      @ftp_port      ||= "2222"
      @top_level_dir ||= "/out"
    end
  end
end
