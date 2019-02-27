require "application_system_test_case"

class AccountInclusionTest < ApplicationSystemTestCase

  test "new account in transaction form" do
    """
    Create a new account
    The new account is inserted using Ajax
    Without refreshing the page, go to 'New Transaction' and check if the newly created account is an option in the account selectors
    """
    account_name = "include this account in transaction form"

    login_as_blank

    # Open the new account menu
    page.find("#new-account-button").click
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Fill in an account name
    fill_in "account[name]", with: account_name
    # Save the account
    click_on "Create Account"
    
    sleep 1
    click_on "New Transaction"
    sleep 1

    # select the new account from the account selector. If it's not available, it will throw an error
    select account_name, from: "Account"

    # select the new account from the account selector. If it's not available, it will throw an error
    page.find("#transactionform #type-transfer").click
    select account_name, from: "From account"
    select account_name, from: "To account"

  end
  
end
