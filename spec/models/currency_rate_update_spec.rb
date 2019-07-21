# == Schema Information
#
# Table name: currency_rate_updates
#
#  id         :bigint           not null, primary key
#  currency   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe CurrencyRateUpdate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
