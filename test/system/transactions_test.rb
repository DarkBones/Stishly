require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  test "open and close transactions menu" do
    """
    Log in and click on 'new transaction'
    Then close the new transaction menu again
    Expected result:
    - See the new transaction menu when clicking 'new transaction'
    - Being able to click 'new transaction' again after closing the menu
    """

    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # check if user accounts are shown
    assert_selector '#accounts_list', text: "All\n€10,000.00\nCurrent Account\n€10,000.00\nSavings Account\n€0.00"
    
    # click on one of the accounts, and then on new transaction
    page.find("#account_16").click
    click_on "New Transaction"

    # check if the transaction menu is visible
    assert_selector '.card-form__title', text: "Create New Transaction"

    # close the menu
    page.find(".card-form__close").click

    # check if the transaction menu closed, by clicking on new transaction again
    click_on "New Transaction"

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create single expense transaction in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # click on new transaction
    page.find("#account_0").click
    click_on "New Transaction"

    # fill in the details
    fill_in "Description", with: "single expense euro"
    fill_in "Amount", with: "100.01"

    click_on "Save Transaction"

    assert_selector '#transactions_list', text: "Today\n€-100.01\nsingle expense euro\n€-100.01"
    assert_selector '#accounts_list', text: "All\n€9,899.99\nCurrent Account\n€9,899.99"

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create multiple expense transactions in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # click on new transaction
    page.find("#account_0").click
    click_on "New Transaction"

    # fill in the details
    fill_in "Description", with: "multiple expense euro"
    page.check('transaction_multiple_transactions')
    fill_in "Transactions", with: "one 1\ntwo 2\nthree 3\nfour 4\npoint 05 .05"

    click_on "Save Transaction"

    page.find('.show-child-transactions').click

    assert_selector '#transactions_list', text: "Today\n€-10.05\nmultiple expense euro\n€-10.05\none\n€-1.00\ntwo\n€-2.00\nthree\n€-3.00\nfour\n€-4.00\npoint 05\n€-0.05"
    assert_selector '#accounts_list', text: "All\n€9,989.95\nCurrent Account\n€9,989.95"

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create single income transaction in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"

    # fill in the details
    fill_in "Description", with: "single income euro"
    select "Income", from: "Type"
    fill_in "Amount", with: "100.01"

    click_on "Save Transaction"

    assert_selector '#transactions_list', text: "Today\n€100.01\nsingle income euro\n€100.01"
    assert_selector '#accounts_list', text: "All\n€10,100.01\nCurrent Account\n€10,100.01"

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create multiple income transactions in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # click on new transaction
    page.find("#account_0").click
    click_on "New Transaction"

    # fill in the details
    fill_in "Description", with: "multiple expense euro"
    select "Income", from: "Type"
    page.check('transaction_multiple_transactions')
    fill_in "Transactions", with: "one 1\ntwo 2\nthree 3\nfour 4\npoint 05 .05"

    click_on "Save Transaction"

    page.find('.show-child-transactions').click

    assert_selector '#transactions_list', text: "Today\n€10.05\nmultiple expense euro\n€10.05\none\n€1.00\ntwo\n€2.00\nthree\n€3.00\nfour\n€4.00\npoint 05\n€0.05"
    assert_selector '#accounts_list', text: "All\n€10,010.05\nCurrent Account\n€10,010.05"

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create single transfer transaction in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"

    # fill in the details
    fill_in "Description", with: "single transfer euro"
    select "Transfer", from: "Type"
    select "Savings Account", from: "To account"
    fill_in "Amount", with: "5000"

    click_on "Save Transaction"

    take_screenshot
    assert_selector '#transactions_list', text: "Today\n€0.00\nsingle transfer euro\n€-5,000.00\nsingle transfer euro\n€5,000.00"
    assert_selector '#accounts_list', text: "All\n€10,000.00\nCurrent Account\n€5,000.00\nSavings Account\n€5,000.00"

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create multiple transfer transactions in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create single expense transaction in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create multiple expense transactions in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create single income transaction in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create multiple income transactions in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create single transfer transaction in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

  test "create multiple transfer transactions in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    

    page.find(".navbar__menu-toggle").click
    click_on "Sign out"
  end

end
