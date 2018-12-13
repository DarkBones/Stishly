require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  test "view transactions in account" do
    """
    Log in and view the accounts on the left menu
    Expected result:
    - See transactions belonging to the account
    """

    login_user(users(:bas), "SomePassword123^!")

    accounts = page.find("#accounts_list").all("li")
    accounts.each do |a|
      puts a.text
      a.click

      accounts = page.find("#accounts_list").all("li")
    end

    take_screenshot
  end
end
