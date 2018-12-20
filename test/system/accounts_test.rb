require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  test "create blank account" do
    """
    Create a new account with no name
    Expected result:
    - See error about invalid account name
    """

    login_as_blank

    page.find("#create-account-button").click

    click_on "Create"

    #take_screenshot

    assert_selector '#flash_alert', text: I18n.t('account.failure.invalid_name')
  end

  test "create duplicate account" do
    """
    Create an account with the same name twice
    Expected result:
    - See error about account already existing
    """

    login_as_blank

    2.times do
      page.find("#create-account-button").click
      fill_in "account_account_string", with: "duplicate account 0.00"
      click_on "Create"
    end

    assert_selector '#flash_alert', text: I18n.t('account.failure.already_exists')

    #take_screenshot
  end

  test "create accounts from string" do
    """
    Create new accounts from string
    Expected result:
    - See new accounts in left menu
    """

    login_as_blank

    account_strings = [
      {
        string: "Test account",
        result: "Test account\n€ 0.00"
      },
      {
        string: "Test 10",
        result: "Test\n€ 10.00"
      },
      {
        string: "Test 1 .10",
        result: "Test 1\n€ 0.10"
      },
      {
        string: "Test 2 99.66",
        result: "Test 2\n€ 99.66"
      },
      {
        string: "Test 3 100.06",
        result: "Test 3\n€ 100.06"
      },
      {
        string: "Test 4 10.5",
        result: "Test 4\n€ 10.50"
      },
      {
        string: "404",
        result: "404\n€ 0.00"
      },
      {
        string: "Negative -10.5",
        result: "Negative\n€ -10.50"
      },
      {
        string: "3.50",
        result: "3.50\n€ 0.00"
      },
      {
        string: "comma test 3,50",
        result: "comma test\n€ 3.50"
      },
      {
        string: "many dots test 9.87.65.43.21",
        result: "many dots test 9.87.65.43.21\n€ 0.00"
      },
      {
        string: "just a bunch of dots ...",
        result: "just a bunch of dots ...\n€ 0.00"
      },
      {
        string: "99.99",
        result: "99.99\n€ 0.00"
      }
    ]

    account_strings.each_with_index do |s, i|
      if i <= 1
        assert_no_selector "#accounts_list", text: "all"
      end

      page.find("#create-account-button").click

      fill_in "account_account_string", with: s[:string]

      click_on "Create"

      assert_selector '#accounts_list', text: s[:result]
    end

    assert_selector '#accounts_list', text: "all\n€ 213.32"

    #take_screenshot
  end

  test "Visit account" do
    user = users(:bas)
    password = "SomePassword123^!"
    login_user(user, password)

    account_name = "Current account"

    visit "/account/" + URI.encode(account_name)

    take_screenshot
  end
end
