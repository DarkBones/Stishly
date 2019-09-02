# == Schema Information
#
# Table name: currency_rates
#
#  id            :bigint           not null, primary key
#  from_currency :string(255)
#  to_currency   :string(255)
#  rate          :float(24)
#  used_count    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CurrencyRate < ApplicationRecord

  def self.update_rates(currency=nil)
    UpdateRates.new(currency).perform
  end

  # populates any conversion combinations that may be missing
  def self.populate_currency_rates
    puts "..populating currency rates"
    Money::Currency.all.each do |from|
      Money::Currency.all.each do |to|
        rate = CurrencyRate.where("from_currency = ? AND to_currency = ?", from.to_s, to.to_s)
        if rate.length == 0
          new_rate = CurrencyRate.new({
            from_currency: from.to_s,
            to_currency: to.to_s,
            used_count: 0
          })
          new_rate.save!
        end
      end
    end
  end

  # populates any conversion rates that are null
  def self.populate_missing_rates
    puts "..populating missing rates"
    
  end

  def self.get_rate(from, to)
    currency_rate_record = self.where(from_currency: from, to_currency: to).order(:created_at).reverse_order().take
    if currency_rate_record.nil?
      self.update_rates(to)
    end

    currency_rate_record = self.where(from_currency: from, to_currency: to).order(:created_at).reverse_order().take
    return 0 if currency_rate_record.nil?

    return currency_rate_record.rate
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
    return new_amount

    #return amount.class.name
  end
end
