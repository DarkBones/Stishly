require 'test_helper'

class AccountTest < ActiveSupport::TestCase

	test 'calculate daily budget' do
		user = users(:daily_budget)

		User.daily_budget(user)
	end

end