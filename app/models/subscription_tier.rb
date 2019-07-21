# == Schema Information
#
# Table name: subscription_tiers
#
#  id                  :bigint           not null, primary key
#  name                :string(255)
#  cost                :integer
#  month_billing_cycle :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  max_accounts        :integer          default(3)
#  max_fixed_expenses  :integer          default(10)
#

class SubscriptionTier < ApplicationRecord
  has_many :users
end
