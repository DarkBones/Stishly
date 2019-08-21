require "application_system_test_case"

class TransactionMenuTest < ApplicationSystemTestCase

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
  end

  test "default transaction menu fields" do
    """
    Log in and click on 'new transaction'
    The following fields are visible from the start:
    - #single-account
    - #categories
    - #amount
    The following fields are hidden from the start:
    - #transfer-account
    - #currency-rate
    - #currency-result
    - #transactions
    """
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # open the transaction menu
    click_on "New Transaction"

    # assert the visible fields
    assert_selector '#single-account', visible: :visible
    assert_selector '#categories', visible: :visible
    assert_selector '#amount', visible: :visible

    # assert the hidden fields
    assert_selector '#transfer-account', visible: :hidden
    assert_selector '#currency-rate', visible: :hidden
    assert_selector '#currency-result', visible: :hidden
    assert_selector '#transactions', visible: :hidden
  end

  test "show and hide fields" do
    """
    Log in and click on 'new transaction'
    1. Click on 'Transfer'
        The following fields are visible
        - #transfer-account
        The following fields are hidden
        - #single-account
        - #categories
    2. Click on 'Multiple'
        The following fields are visible
        - #transactions
        The following fields are hiddden
        - #amount
    3. Select account JPY
        The folowin fields are hidden
        - #currency-rate
        - #currency-result
    4. Select currency 'JPY'
        The following fields are visible
        - #currency-rate
        - #currency-result
    5. Select currency 'EUR'
        The following fields are hidden
        - #currency-rate
        - #currency-result
    6. Select account JPY
        The folowing fields are visible (because we changed the currency manually, overriding the account currency)
        - #currency-rate
        - #currency-result
    """

    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # open the transaction menu
    click_on "New Transaction"

    # TRANSFER
    page.find("#transactionform #type-transfer").click
    # assert visible
    assert_selector '#transfer-account', visible: :visible
    # assert hidden
    assert_selector '#single-account', visible: :hidden
    assert_selector '#categories', visible: :hidden
    page.find("#transactionform #type-expense").click

    # MULTIPLE
    page.find("#transactionform #multiple-multiple").click
    # assert visible
    assert_selector '#transactions', visible: :visible
    # assert hidden
    assert_selector '#amount', visible: :hidden

  end

  test "live currency conversion" do
    """
    Log in and click on 'new transaction'
    Select JPY as currency
    - Currency rate should be 0.008
    - Account currency should be 0
    fill in amount = 10000
    - Account currency should be 80
    Select Multiple
    Fill in transactions:
        one 10000
        two 20000
        three 30000
        four 40000
    - Account currency should be 800
    """
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # open the transaction menu
    click_on "New Transaction"
    select "JPY", from: "Currency"

    assert page.find("#transaction_rate").value == '0.008'
    assert page.find("#transaction_account_currency").value == '0'

    fill_in "Amount", with: "10000"
    assert page.find("#transaction_account_currency").value.to_f > 0

    page.find("#transactionform #multiple-multiple").click
    sleep 2
    wait_for_ajax
    assert page.find("#transaction_account_currency").value.to_i == 0

    while page.find("#transaction_transactions").value != "one 100000\n" do
        fill_in "Transactions", with: "one 100000\n"
    end

    #fill_in "Transactions", with: "one 100000"
    wait_for_ajax
    assert page.find("#transaction_account_currency").value.to_f > 0

    #assert_selector '#transaction_total', text: "Total: ¥100,000"
  end

end
