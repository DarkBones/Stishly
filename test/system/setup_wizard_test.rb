require "application_system_test_case"

class SetupWizardTest < ApplicationSystemTestCase
  test "visit welcome wizard" do
    login_user(users(:setup_wizard), 'SomePassword123^!')

    # check for the welcome message
    assert_selector 'h1', text: "Welcome"

    # only the first fieldset should be visible
    assert_selector '#userwizzard fieldset:first-of-type', visible: :visible
    assert_selector '#userwizzard fieldset:not(:first-of-type)', visible: :hidden

  end

  test "country and currency" do
    login_user(users(:setup_wizard), 'SomePassword123^!')

    # click on next, there should be an error saying no country was selected
    click_on "Next"
    assert_selector '#flash_alert', text: "No country selected"

    # select ireland and check if the currency is correctly populated with EUR
    find("#user_country").find(:option, "Ireland").select_option
    assert find("#user_currency").value == "EUR", format_error("Unexpected currency after country select", "EUR", find("#user_currency").value)

    # select no currency
    # click on next, there should be an error saying no currency was selected
    find("#user_currency").find(:option, "").select_option
    click_on "Next"
    assert_selector '#flash_alert', text: "No currency selected"

    # select a currency and a different country
    find("#user_currency").find(:option, "JPY").select_option
    find("#user_country").find(:option, "Canada").select_option
    # the currency should not have changed automatically as it was set manually by the user
    assert find('#user_currency').value == "JPY", format_error("Unexpected currency", "JPY", find('#user_currency').value)

    # select EUR currency
    find("#user_currency").find(:option, "EUR").select_option

    # go to the next fieldset
    click_on "Next"

    # check if the second fieldset is now visible and the first one is not
    assert_selector '#userwizzard fieldset:first-of-type', visible: :hidden
    assert_selector '#userwizzard fieldset:nth-of-type(2)', visible: :visible

    # check if the currency is correctly set to EUR
    assert find('#account_currency_0').value == "EUR", format_error("Unexpected account currency", "EUR", find('#account_currency_0').value)

    # go back and change the currency to CAD
    #click_on "Previous"
    previous

    find("#user_currency").find(:option, "CAD").select_option
    click_on "Next"
    assert find('#account_currency_0').value == "CAD", format_error("Unexpected account currency", "CAD", find('#account_currency_0').value)

    # change the account currency manually
    find("#account_currency_0").find(:option, "JPY").select_option

    # go back and change the currency to EUR. The account currency should not update as it was set manually by the user
    previous
    find("#user_currency").find(:option, "EUR").select_option
    click_on "Next"
    assert find('#account_currency_0').value == "JPY", format_error("Unexpected account currency", "JPY", find('#account_currency_0').value)

  end

  test "all fieldsets" do
    login_user(users(:setup_wizard), 'SomePassword123^!')
    find("#user_country").find(:option, "Ireland").select_option
    click_on "Next"

    # click on next without filling in an account. Should raise an error
    sleep 5
    click_on "Next"
    click_on "Next"
    assert_selector '#flash_alert', text: "Create at least one account"

    # check if the minus button is disabled
    assert find('#remove_account_row')['class'].match(/disabled/), format_error("Remove Account Row is not disabled")

    # Fill in the first account
    find("#account_name_0").set("First account")
    find("#account_balance_0").set("111.11")
    find("select[name='account_type_0']").set("spend")

    # Create a second account
    find(".plusmin:first-of-type").click
    # Check if the new account row was inserted
    assert page.has_css?('#account_name_1'), format_error("New account row wasn't inserted")
    # Check if the currency populated accordingly
    assert find('#account_currency_1').value == "EUR", format_error("Currency in new account row did not populate")
    # Check if the minus button is activated
    assert_not find('#remove_account_row')['class'].match(/disabled/), format_error("Remove account row button is disabled")
    # remove the account again
    find("#remove_account_row").click
    # check if the row has been removed
    assert_not page.has_css?('#account_name_1'), format_error("Account row was not removed")
    # check if the remove button is disabled again
    assert find('#remove_account_row')['class'].match(/disabled/), format_error("Remove Account Row is not disabled")
    # create the account again
    find(".plusmin:first-of-type").click

    # Fill in the second account
    find("#account_name_1").set("Second Account")
    find("#account_balance_1").set("222.22")
    find("#account_currency_1").find(:option, "CAD").select_option

    # Create a third account without a name
    find(".plusmin:first-of-type").click
    find("#account_balance_2").set("333.33")
    find("#account_currency_2").find(:option, "JPY").select_option

    # Click on next, it should raise an error
    click_on "Next"
    assert_selector '#flash_alert', text: "Fill in a name for each account"
    # Fill in a duplicate name
    find("#account_name_2").set("Second Account")
    click_on "Next"
    assert_selector '#flash_alert', text: "No duplicate account names allowed"
    # Fill in an accepted name
    find("#account_name_2").set("Third Account")

    # Create more than the maximum allowed accounts
    find(".plusmin:first-of-type").click
    assert_selector '#flash_alert', text: "Upgrade to premium for more accounts"

    # Check if the dropdown menus are populated
    click_on "Next"
    find("select[name='regularity']").find(:option, "I get paid on regular intervals").select_option
    
    find('#account_income').find(:option, "First account (EUR)").select_option
    find('#account_income').find(:option, "Second Account (CAD)").select_option
    find('#account_income').find(:option, "Third Account (JPY)").select_option
    
    find("select[name='regularity']").find(:option, "I don't have an income").select_option

  end
    
    # workaround to go to the first fieldset
    def previous()
        while assert_selector '#userwizzard fieldset:nth-of-type(1)', visible: :visible == false do
            if page.has_css?(".previous")
                begin
                    click_on "Previous" if page.has_css?(".previous")
                rescue
                    #
                end
            else
                break
            end
        end
    end
end