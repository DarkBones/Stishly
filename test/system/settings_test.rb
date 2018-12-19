require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  test "Change user currency" do
    """
    Change the currency user setting
    Expected result:
    - See new currency selected in dropdown menu
    - See new currency in all accounts
    """

    user = users(:bas)
    password = "SomePassword123^!"

    login_user(user, password)

    click_on "Settings"

    select "JPY - Japanese Yen", from: "setting_value_currency"

    click_on "Save"

    assert_selector '#accounts_list', text: "all\n¥ 257"

    take_screenshot
  end

  test "Change account currency" do
    """
    Change the currency account setting
    Expected result:
    - See new currency in account listing
    - Account balance converted
    """
  end
