class CurrencyRate
  class GetCurrencyRate

    def initialize(currency)
      @api_key = Rails.application.credentials.concurrency[:api_key]
      @base_url = 'https://v3.exchangerate-api.com/bulk/'
      @currency = currency
    end

    def perform
      response = make_request
      result = parse_response(response)

      puts result

      rates = result["rates"]

      if rates
        rates.each do |currency, rate|
          CurrencyRate.update_rate(@currency, currency, rate)
        end

        return rates[@currency]
      else
        return 0
      end
    end

    def make_request
      require 'net/http'
      require 'json'
      require 'yaml'

      url = @base_url + @api_key + '/' + @currency
      uri = URI(url)
      response = Net::HTTP.get(uri)

      return response
    end

    def parse_response(response)
      result = JSON.parse(response)
      return result
    end

  end
end