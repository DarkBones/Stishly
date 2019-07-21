# == Schema Information
#
# Table name: currency_rate_updates
#
#  id         :bigint           not null, primary key
#  currency   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CurrencyRateUpdate < ApplicationRecord

	validates :currency, uniqueness: true

	# returns the currency that hasn't been updated the longest
	def self.get_oldest
		# return USD if the currency_rates table is empty
		return "USD" if self.first.nil?

		retention = APP_CONFIG['currency_rates']['retention']
		currency = self.where("updated_at <= ?", retention.seconds.ago).order(:updated_at).take

		return currency.currency unless currency.nil?
		return nil
	end

	# inserts a new currency
	def self.insert_new(currency)
		obj = {
			currency: currency,
			updated_at: Time.parse("Jan 1 1970 00:00")
		}

		currency = self.new(obj)
		currency.save
	end

	# updates the timestamp of a currency
	def self.update_currency(currency)
		currency = self.where(currency: currency).take
		return if currency.nil?
		currency.updated_at = Time.now
		currency.save
	end

end
