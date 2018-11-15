# == Schema Information
#
# Table name: accounts
#
#  id          :bigint(8)        not null, primary key
#  balance     :integer
#  currency_id :bigint(8)
#  user_id     :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
end
