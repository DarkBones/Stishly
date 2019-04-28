# == Schema Information
#
# Table name: transactions
#
#  id                      :bigint(8)        not null, primary key
#  user_id                 :bigint(8)
#  amount                  :integer
#  direction               :integer
#  description             :string(100)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  account_id              :integer
#  timezone                :string(255)      not null
#  currency                :string(255)
#  account_currency_amount :integer
#  category_id             :bigint(8)
#  parent_id               :bigint(8)
#  exclude_from_all        :boolean          default(FALSE)
#  local_datetime          :datetime         not null
#  transfer_account_id     :bigint(8)
#  user_currency_amount    :integer          not null
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
