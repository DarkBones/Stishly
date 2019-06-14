# == Schema Information
#
# Table name: currency_rates
#
#  id            :bigint(8)        not null, primary key
#  from_currency :string(255)
#  to_currency   :string(255)
#  rate          :float(24)
#  used_count    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CurrencyRate < ApplicationRecord
  def self.get_rate(from, to)
    currency_rate_record = self.where(from_currency: from, to_currency: to, updated_at: 1.days.ago..Time.now).take
    if currency_rate_record
      return currency_rate_record.rate
    end

    require 'money/bank/open_exchange_rates_bank'

    oxr = Money::Bank::OpenExchangeRatesBank.new
    oxr.app_id = Rails.application.credentials.openexchangerates[:api_key]
    oxr.update_rates

    oxr.cache = '/tmp/cache/exchange_rates.json'
    oxr.ttl_in_seconds = 86400

    Money.default_bank = oxr
    rate = Money.default_bank.get_rate(from, to).to_f

    self.update_rate(from, to, rate)
    return rate
  end

  def self.update_rate(from, to, rate)
    currency_rate = self.where(from_currency: from, to_currency: to).take
    if currency_rate
      currency_rate.rate = rate
      currency_rate.used_count = currency_rate.used_count + 1
      currency_rate.save
    else
      new_rate = self.new
      new_rate.from_currency = from
      new_rate.to_currency = to
      new_rate.rate = rate
      new_rate.used_count = 1
      new_rate.save
    end
  end

  def self.convert(amount, from, to, rate=nil)
    from = Money::Currency.new(from) if from.class == String
    to = Money::Currency.new(to) if to.class == String

    rate ||= self.get_rate(from.to_s, to.to_s)

    amount_float = amount
    amount_float = amount.to_f / from.subunit_to_unit if amount.class == Integer
    new_amount = amount_float * rate

    return (new_amount * to.subunit_to_unit).round.to_i if amount.class == Integer
    return amount
  end
end
