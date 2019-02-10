require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  test "new transactions menu" do
    """
    Log in and click on 'new transaction'
    Then close the new transaction menu again
    Expected result:
    - See the new transaction menu when clicking 'new transaction'
    - Being able to click 'new transaction' again after closing the menu
    """

    user = users(:transactions)

    login_user(user, 'SomePassword123^!')

    take_screenshot
  end

end
