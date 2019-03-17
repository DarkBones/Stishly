# == Schema Information
#
# Table name: account_histories
#
#  id             :bigint(8)        not null, primary key
#  account_id     :bigint(8)
#  local_datetime :datetime
#  balance        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class AccountHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
