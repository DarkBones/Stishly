require "application_system_test_case"

class UpcomingTransactionsTest < ApplicationSystemTestCase

  test "See upcoming transactions" do
  	#current_user = users(:upcoming_transactions)
  	#login_user(current_user, 'SomePassword123^!')

  	login_as_blank

  	page.find(".navbar-gear").click
    click_on "Upcoming Transactions"

    assert_selector "p", text: "No transactions scheduled for now"
  end

end