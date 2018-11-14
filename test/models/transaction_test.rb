# == Schema Information
#
# Table name: transactions
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)
#  amount      :integer
#  direction   :integer
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
