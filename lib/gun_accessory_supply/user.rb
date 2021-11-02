module GunAccessorySupply
  class User < Base

    USER_DIR             = '/ammoready'
    USER_FILENAME_PREFIX = ''

    def initialize(options = {})
      requires!(options, :username, :password, :account_id)
      @options = options
    end

    def authenticated?
      tempfile = get_most_recent_file(USER_FILENAME_PREFIX, USER_DIR)

      File.open(tempfile).each_with_index do |row, i|
        row = row.split("\t")

        return true if row[0].strip.downcase == @options[:account_id].strip.downcase
      end

      false
    rescue GunAccessorySupply::NotAuthenticated
      false
    end

  end
end
