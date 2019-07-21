# == Schema Information
#
# Table name: account_histories
#
#  id             :bigint           not null, primary key
#  account_id     :bigint
#  local_datetime :datetime
#  balance        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class AccountHistoryTest < ActiveSupport::TestCase
  
end
