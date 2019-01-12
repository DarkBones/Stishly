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

    page.find(".navbar__menu-toggle").click

    click_on "Settings"

    select "JPY", from: "setting_value_currency"

    click_on "Save"

    assert_selector '#accounts_list', text: "All\n¥ 248"

    take_screenshot
  end
end
