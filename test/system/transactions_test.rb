=begin
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
    assert_selector '#accounts_list', text: "All\n€10,000.00"
    assert_selector '#accounts_list', text: "Current Account\n€10,000.00"
    assert_selector '#accounts_list', text: "Savings Account\n€0.00"
    
    # click on one of the accounts, and then on new transaction
    page.find("#account_16").click
    click_on "New Transaction"

    # check if the transaction menu is visible
    assert_selector '#transactionform', visible: :visible

    # close the menu
    page.find("#transactionform button.close").click

    # check if menu is hidden
    assert_selector '#transactionform', visible: :hidden

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple transactions" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    5.times do
        # click on new transaction
        page.find("#account_0").click
        click_on "New Transaction"
        #sleep 15

        # fill in the details
        fill_in "Description", with: "single expense euro"
        fill_in "Amount", with: "100"

        click_on "Create Transaction"
        sleep 1
    end

    wait_for_ajax

    assert_selector '#transactions_list', text: "Today\n€-500.00"
    assert_selector '#transactions_list', text: "single expense euro\n€-100.00"

    assert_selector '#accounts_list', text: "All\n€9,500.00"
    assert_selector '#accounts_list', text: "Current Account\n€9,500.00"
  end

  test "create single expense transaction in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # click on new transaction
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "single expense euro"
    fill_in "Amount", with: "100.01"

    click_on "Create Transaction"

    assert_selector '#transactions_list', text: "Today\n€-100.01"
    assert_selector '#transactions_list', text: "single expense euro\n€-100.01"

    assert_selector '#accounts_list', text: "All\n€9,899.99"
    assert_selector '#accounts_list', text: "Current Account\n€9,899.99"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple expense transactions in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # click on new transaction
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "multiple expense euro"
    page.find("#transactionform #multiple-multiple").click
    fill_in "Transactions", with: "one 1\r\ntwo 2\r\nthree 3\r\nfour 4\r\npoint 05 .05"

    click_on "Create Transaction"

    assert_selector '.child_transactions', visible: :hidden
    page.find('.show-child-transactions').click
    assert_selector '.child_transactions', visible: :visible

    assert_selector '#transactions_list', text: "Today\n€-10.05"
    assert_selector '#transactions_list', text: "multiple expense euro\n€-10.05"

    assert_selector '.child_transactions', text: "one\n€-1.00"
    assert_selector '.child_transactions', text: "two\n€-2.00"
    assert_selector '.child_transactions', text: "three\n€-3.00"
    assert_selector '.child_transactions', text: "four\n€-4.00"
    assert_selector '.child_transactions', text: "point 05\n€-0.05"

    page.find('.show-child-transactions').click
    assert_selector '.child_transactions', visible: :hidden

    assert_selector '#accounts_list', text: "All\n€9,989.95"
    assert_selector '#accounts_list', text: "Current Account\n€9,989.95"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create single income transaction in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "single income euro"
    page.find("#transactionform #type-income").click
    fill_in "Amount", with: "100.01"

    click_on "Create Transaction"

    assert_selector '#transactions_list', text: "Today\n€100.01"
    assert_selector '#transactions_list', text: "single income euro\n€100.01"

    assert_selector '#accounts_list', text: "All\n€10,100.01"
    assert_selector '#accounts_list', text: "Current Account\n€10,100.01"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple income transactions in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # click on new transaction
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "multiple expense euro"
    page.find("#transactionform #type-income").click
    page.find("#transactionform #multiple-multiple").click
    fill_in "Transactions", with: "one 1\ntwo 2\nthree 3\nfour 4\npoint 05 .05"

    click_on "Create Transaction"

    assert_selector '.child_transactions', visible: :hidden
    page.find('.show-child-transactions').click
    assert_selector '.child_transactions', visible: :visible

    assert_selector '#transactions_list', text: "Today\n€10.05"
    assert_selector '#transactions_list', text: "multiple expense euro\n€10.05"
    assert_selector '#transactions_list', text: "one\n€1.00"
    assert_selector '#transactions_list', text: "two\n€2.00"
    assert_selector '#transactions_list', text: "three\n€3.00"
    assert_selector '#transactions_list', text: "four\n€4.00"
    assert_selector '#transactions_list', text: "point 05\n€0.05"
    

    assert_selector '#accounts_list', text: "All\n€10,010.05"
    assert_selector '#accounts_list', text: "Current Account\n€10,010.05"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create single transfer transaction in same currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "single transfer euro"
    page.find("#transactionform #type-transfer").click
    select "Savings Account", from: "To account"
    fill_in "Amount", with: "5000"

    click_on "Create Transaction"
        
    assert_selector '#transactions_list', text: "Today\n€0.00"

    assert_selector '#transactions_list', text: "single transfer euro\n€-5,000.00"
    assert_selector '#transactions_list', text: "single transfer euro\n€5,000.00"

    assert_selector '#transactions_list', text: "Transferred from Current Account"
    assert_selector '#transactions_list', text: "Transferred to Savings Account"

    page.find("#account_16").click
    assert_selector '#transactions_list', text: "Today\n€-5,000.00"
    assert_selector '#transactions_list', text: "single transfer euro\n€-5,000.00"

    page.find("#account_17").click
    assert_selector '#transactions_list', text: "Today\n€5,000.00"
    assert_selector '#transactions_list', text: "single transfer euro\n€5,000.00"

    assert_selector '#accounts_list', text: "All\n€10,000.00"
    assert_selector '#accounts_list', text: "Current Account\n€5,000.00"
    assert_selector '#accounts_list', text: "Savings Account\n€5,000.00"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple transfer transactions in same currency" do
    #page.save_screenshot 'tmp/screenshots/transaction_1.png'
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    #page.save_screenshot 'tmp/screenshots/transaction_2.png'

    # fill in the details
    fill_in "Description", with: "multiple transfer euro"
    page.find("#transactionform #type-transfer").click
    #page.save_screenshot 'tmp/screenshots/transaction_3.png'
    select "Savings Account", from: "To account"
    #page.save_screenshot 'tmp/screenshots/transaction_4.png'
    page.find("#transactionform #multiple-multiple").click
    #page.save_screenshot 'tmp/screenshots/transaction_5.png'
    fill_in "Transactions", with: "one 1\ntwo 2\nthree 3\nfour 4\npoint 05 .05"
    
    #page.save_screenshot 'tmp/screenshots/transaction_6.png'

    click_on "Create Transaction"

    page.find_all('.show-child-transactions')[1].click
    page.find_all('.show-child-transactions')[0].click

    assert_selector '#transactions_list', text: "Today\n€0.00"
    assert_selector '#transactions_list', text: "multiple transfer euro\n€-10.05"
    assert_selector '#transactions_list', text: "one\n€-1.00"
    assert_selector '#transactions_list', text: "two\n€-2.00"
    assert_selector '#transactions_list', text: "three\n€-3.00"
    assert_selector '#transactions_list', text: "four\n€-4.00"
    assert_selector '#transactions_list', text: "point 05\n€-0.05"

    assert_selector '#transactions_list', text: "multiple transfer euro\n€10.05"
    assert_selector '#transactions_list', text: "one\n€1.00"
    assert_selector '#transactions_list', text: "two\n€2.00"
    assert_selector '#transactions_list', text: "three\n€3.00"
    assert_selector '#transactions_list', text: "four\n€4.00"
    assert_selector '#transactions_list', text: "point 05\n€0.05"

    assert_selector '#transactions_list', text: "Transferred from Current Account"
    assert_selector '#transactions_list', text: "Transferred to Savings Account"

    assert_selector '#accounts_list', text: "All\n€10,000.00"
    assert_selector '#accounts_list', text: "Current Account\n€9,989.95"
    assert_selector '#accounts_list', text: "Savings Account\n€10.05"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create single expense transaction in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "single expense jpy"
    page.find("#transactionform #type-expense").click
    select "JPY", from: "Currency"
    fill_in "Amount", with: "100"
        
    click_on "Create Transaction"
        
    assert_selector '#transactions_list', text: "Today\n€-0.80"
    assert_selector '#transactions_list', text: "single expense jpy\n€-0.80"
    assert_selector '#transactions_list', text: "~¥-100"

    assert_selector '#accounts_list', text: "All\n€9,999.20"
    assert_selector '#accounts_list', text: "Current Account\n€9,999.20"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple expense transactions in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "multiple expense jpy"
    select "JPY", from: "Currency"
    page.find("#transactionform #multiple-multiple").click
    fill_in "Transactions", with: "one 100\ntwo 200\nthree 300\nfour 400\n"
    take_screenshot
    click_on "Create Transaction"
        
    assert_selector '#transactions_list', text: "Today\n€-8.00"
    assert_selector '#transactions_list', text: "multiple expense jpy\n€-8.00"
    assert_selector '#transactions_list', text: "~¥-1,000"

    assert_selector '#accounts_list', text: "All\n€9,992.00"
    assert_selector '#accounts_list', text: "Current Account\n€9,992.00"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create single income transaction in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "single income jpy"
    page.find("#transactionform #type-income").click
    select "JPY", from: "Currency"
    fill_in "Amount", with: "100000"

    click_on "Create Transaction"
        
    assert_selector '#transactions_list', text: "Today\n€800.00"
    assert_selector '#transactions_list', text: "single income jpy\n€800.00"
    assert_selector '#transactions_list', text: "~¥100,000"

    assert_selector '#accounts_list', text: "All\n€10,800.00"
    assert_selector '#accounts_list', text: "Current Account\n€10,800.00"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple income transactions in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "multiple income jpy"
    page.find("#transactionform #type-income").click
    select "JPY", from: "Currency"
    page.find("#transactionform #multiple-multiple").click
    #fill_in "Transactions", with: "one 1000\ntwo 2000\nthree 3000\nfour 4000\n"

    page.find("#transactionform #transaction_transactions").set("one 1000\ntwo 2000\nthree 3000\nfour 4000")
    click_on "Create Transaction"

    assert_selector '.child_transactions', visible: :hidden
    page.find('.show-child-transactions').click
    assert_selector '.child_transactions', visible: :visible
        
    assert_selector '#transactions_list', text: "Today\n€80.00"
    assert_selector '#transactions_list', text: "multiple income jpy\n€80.00"
    assert_selector '#transactions_list', text: "one\n€8.00"
    assert_selector '#transactions_list', text: "two\n€16.00"
    assert_selector '#transactions_list', text: "three\n€24.00"
    assert_selector '#transactions_list', text: "four\n€32.00"

    assert_selector '#transactions_list', text: "~¥10,000"
    assert_selector '#transactions_list', text: "~¥1,000"
    assert_selector '#transactions_list', text: "~¥2,000"
    assert_selector '#transactions_list', text: "~¥3,000"
    assert_selector '#transactions_list', text: "~¥4,000"

    assert_selector '#accounts_list', text: "All\n€10,080.00"
    assert_selector '#accounts_list', text: "Current Account\n€10,080.00"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create single transfer transaction in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "single transfer jpy"
    page.find("#transactionform #type-transfer").click
    select "Savings Account", from: "To account"
    select "JPY", from: "Currency"
    fill_in "Amount", with: "100000"

    click_on "Create Transaction"
        
    assert_selector '#transactions_list', text: "Today\n€0.00"
    assert_selector '#transactions_list', text: "single transfer jpy\n€-800.00"
    assert_selector '#transactions_list', text: "single transfer jpy\n€800.00"

    assert_selector '#transactions_list', text: "~¥-100,000"
    assert_selector '#transactions_list', text: "~¥100,000"

    assert_selector '#transactions_list', text: "Transferred from Current Account"
    assert_selector '#transactions_list', text: "Transferred to Savings Account"

    assert_selector '#accounts_list', text: "All\n€10,000.00"
    assert_selector '#accounts_list', text: "Current Account\n€9,200.00"
    assert_selector '#accounts_list', text: "Savings Account\n€800.00"

    page.driver.browser.navigate.refresh
    logout
  end

  test "create multiple transfer transactions in different currency" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "multiple transfer jpy"
    page.find("#transactionform #type-transfer").click
    select "Savings Account", from: "To account"
    select "JPY", from: "Currency"
    page.find("#transactionform #multiple-multiple").click
    fill_in "Transactions", with: "one 1000\ntwo 2000\nthree 3000\nfour 4000\n"
    
    click_on "Create Transaction"
    
    assert_selector '#transactions_list', text: "Today\n€0.00"
    assert_selector '#transactions_list', text: "multiple transfer jpy\n€-80.00"
    assert_selector '#transactions_list', text: "multiple transfer jpy\n€80.00"

    assert_selector '#transactions_list', text: "~¥-10,000"
    assert_selector '#transactions_list', text: "~¥10,000"

    assert_selector '#transactions_list', text: "Transferred from Current Account"
    assert_selector '#transactions_list', text: "Transferred to Savings Account"

    assert_selector '#accounts_list', text: "All\n€10,000.00"
    assert_selector '#accounts_list', text: "Current Account\n€9,920.00"
    assert_selector '#accounts_list', text: "Savings Account\n€80.00"

    page.driver.browser.navigate.refresh
    logout
  end
    
  test "transaction currency resetting" do
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click
    click_on "New Transaction"
    #sleep 15

    # fill in the details
    fill_in "Description", with: "JPY"
    select "JPY", from: "Currency"
    fill_in "Amount", with: "1000"

    click_on "Create Transaction"

    click_on "New Transaction"
    #sleep 15
    page.driver.browser.navigate.refresh
    logout
  end

end
=end