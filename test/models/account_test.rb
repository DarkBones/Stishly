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

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
