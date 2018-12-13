require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  test "create account" do
    """
    Create a new account
    Expected result:
    - See new account in the left menu
    """

    login_as_blank

    page.find("#create-account-button").click

    #fill_in "account_account_string", with: "Test account 900"

    click_on "Create"

    sleep 1.5

    take_screenshot
  end
end
