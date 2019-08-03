# == Schema Information
#
# Table name: currencies
#
#  id              :bigint           not null, primary key
#  name            :string(255)
#  symbol          :string(255)
#  iso_code        :string(255)
#  number_to_basic :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Currency < ApplicationRecord
  has_many :countries

  def self.float_to_int(amount, currency)
  	currency = Money::Currency.new(currency)
  	amount = amount.to_f

  	return (amount * currency.subunit_to_unit).round().to_i
  end

  def self.int_to_float(amount, currency)
  	currency = Money::Currency.new(currency)
  	amount = amount.to_f

  	return amount / currency.subunit_to_unit
  end

end
