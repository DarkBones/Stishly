# == Schema Information
#
# Table name: subscription_tiers
#
#  id                  :bigint(8)        not null, primary key
#  name                :string(255)
#  cost                :integer
#  month_billing_cycle :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class SubscriptionTierTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
