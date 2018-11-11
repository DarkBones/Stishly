class User < ApplicationRecord
  has_many :transactions
  has_many :accounts
  belongs_to :country
  belongs_to :subscription_tier
end
