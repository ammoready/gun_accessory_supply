module GunAccessorySupply
  class Tracking < Base

    BASE_TRACKING_FILE_DIRECTORY = "%s-TRACK".freeze
    BASE_TRACKING_FILE_NAME = "%s_PackageTracking.csv".freeze
    CARRIER = 'UPS'.freeze

    def initialize(options = {})
      requires!(options, :username, :password, :dealer_number)

      @options = options
      @dealer_number = options[:dealer_number]
    end

    def self.fetch_data(options = {})
      requires!(options, :username, :password, :dealer_number)

      new(options).fetch_data
    end

    def fetch_data
      tracking_file_name = BASE_TRACKING_FILE_NAME % @dealer_number
      tracking_file_directory = BASE_TRACKING_FILE_DIRECTORY % @dealer_number
      tracking_file = get_file(tracking_file_name, tracking_file_directory)

      tracking_details = CSV.foreach(tracking_file, { headers: :first_row }).map do |row|
        {
          po_number: row['USR_VEND_ORD_NO'],
          carrier: CARRIER,
          tracking_numbers: [row['TRK_NO_1'], row['TRK_NO_2'], row['TRK_NO_3'], row['TRK_NO_4'], row['TRK_NO_5']].reject(&:blank?),
        }
      end

      tracking_file.unlink

      tracking_details
    end

  end
end
