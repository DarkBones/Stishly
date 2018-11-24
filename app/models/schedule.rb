class Schedule < ApplicationRecord
  has_many :transactions
  belongs_to :user
  belongs_to :account
end
