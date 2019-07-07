class CurrencyRate
  class UpdateRates
  	
  	def initialize(source=nil)
  		@source = source
  	end

  	def perform
  		@source ||= get_oldest_rate
  		run_updates(@source)
  	end

  	def update_all
  		source_currencies = CurrencyRateUpdate.all
  		source_currencies.each do |source|
  			run_updates(source.currency)
  		end
  	end

private

		def run_updates(source)
			return if source.nil?

			rates = get_rates(source)
			process_rates(rates)
			CurrencyRateUpdate.update_currency(@source)
		end
		
		# returns the currency iso code that hasn't been update the longest
		def get_oldest_rate
			return CurrencyRateUpdate.get_oldest
		end

		# returns all exchange rates given the source currency
		def get_rates(source)
			require 'money/bank/open_exchange_rates_bank'
			oxr = Money::Bank::OpenExchangeRatesBank.new
			oxr.app_id = Rails.application.credentials.openexchangerates[:api_key]
	    oxr.source = source
	    oxr.update_rates

	    oxr.cache = '/tmp/cache/exchange_rates.json'
	    oxr.ttl_in_seconds = 86400

	    return oxr.rates
		end

		# processes the currency rates
		def process_rates(rates)
			rates.each do |r|
				currencies = r[0].split("_TO_")
				from = currencies[0]
				to = currencies[1]
				rate = r[1]
				save_rate(from, to, rate)

				# save the currencies to the currency_rate_update table in case they weren't logged yet
				CurrencyRateUpdate.insert_new(from)
				CurrencyRateUpdate.insert_new(to)
			end
		end

		# saves the rate to the db
		def save_rate(from, to, rate)
			obj = {
				from_currency: from,
				to_currency: to,
				rate: rate,
				used_count: 0
			}

			currency_rate = CurrencyRate.new(obj)
			currency_rate.save
		end

  end
end