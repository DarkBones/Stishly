# == Schema Information
#
# Table name: daily_budgets
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  spent      :integer
#  amount     :integer
#  currency   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase

	test 'calculate daily budget' do
		user = users(:daily_budget)

		User.daily_budget(user)
	end

end
