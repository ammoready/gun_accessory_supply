module GunAccessorySupply
  class User < Base

    STANDARD_CUSTOMER_NUMBER_LENGTH = 6.freeze

    def initialize(options = {})
      requires!(options, :username, :password)

      @customer_number = options[:username]
    end

    def authenticated?
      @customer_number.length == STANDARD_CUSTOMER_NUMBER_LENGTH && @customer_number[0].to_i == 1
    end

  end
end
