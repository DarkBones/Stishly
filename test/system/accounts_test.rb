require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  test "Account creation tests" do

    login_as_blank

    page.driver.browser.navigate.refresh

    # Open the new account menu
    page.find("#new-account-button").click
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Check if button is disabled correctly
    assert submit[:disabled], format_error("Save account button not disabled when name is blank", "disabled = true", "disabled = " + submit[:disabled].to_s)
    # Fill in an account name
    fill_in "account[name]", with: "test account one"
    # Check if the button is enabled correctly
    assert submit[:disabled] == nil, format_error("Save account button disabled", "disabled = nil", "disabled = " + submit[:disabled].to_s)
    # Save the account
    click_on "Create Account"
    page.driver.browser.navigate.refresh

    # Open the new account menu
    click_on "New Account"
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Fill in the details
    fill_in "account[name]", with: "test. account. two"
    fill_in "account[balance]", with: "5000"
    fill_in "account[description]", with: "Test description"
    # Save the account
    click_on "Create Account"
    page.driver.browser.navigate.refresh

    # Open the new account menu
    click_on "New Account"
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Fill in the same name as the previous account
    fill_in "account[name]", with: "test. account. two"
    # Save the account
    click_on "Create Account"
    page.driver.browser.navigate.refresh
    # TODO: Check if the duplicate account error shows

    #@selenium.wait_for_element
    #assert_selector '#accountform', text: "New Account"

    #page.find("#accountform button.close").click

    # Open the new account menu
    click_on "New Account"
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Fill in the details
    fill_in "account[name]", with: "test account three"
    fill_in "account[balance]", with: "10000.42"
    # Save the account
    click_on "Create Account"
    page.driver.browser.navigate.refresh

    # Open the new account menu
    click_on "New Account"
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Fill in the details
    fill_in "account[name]", with: "test account four"
    fill_in "account[balance]", with: "50000"
    select "JPY", from: "account[currency]"
    # Save the account
    click_on "Create Account"
    page.driver.browser.navigate.refresh

    #puts page.driver.browser.manage.logs.get(:browser)

    # Open the new account menu
    click_on "New Account"
    # Find and store the submit button
    submit = page.find("#accountform input[type=submit]")
    # Fill in the details
    fill_in "account[name]", with: "test account five"
    fill_in "account[balance]", with: "0.08"
    # Save the account
    click_on "Create Account"
    page.driver.browser.navigate.refresh

    # Check if the new accounts shows up in the left menu
    assert_selector '#accounts_list', text: "All\n€15,400.50\ntest account five\n€0.08\ntest account four\n¥50,000\ntest account three\n€10,000.42\ntest account two\n€5,000.00\ntest account one\n€0.00"
  end

  test "Transaction visible test" do

    current_user = users(:bas)

    login_user(current_user, 'SomePassword123^!')

    for i in 1..5
        page.find("#account_#{i}").click

        for x in 1..i
            assert_selector 'li', text: "transaction " + x.to_s + "\n€#{x}.00"
        end
    end

    take_screenshot

  end

  test "Endless page test" do
    current_user = users(:endless_page)

    login_user(current_user, 'SomePassword123^!')

    page.find("#account_13").click

    sleep 1
    assert_selector 'li', text: "transaction 1\n€1.00"
    assert_select 'li', {count: 0, text: "transaction 100"}

    5.times do
        page.execute_script "window.scrollBy(0,10000)"
        sleep 1
    end

    assert_selector 'li', text: "transaction 100"

    take_screenshot
  end
  
end
