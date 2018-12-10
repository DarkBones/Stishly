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

require 'test_helper'

class CurrencyRateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
