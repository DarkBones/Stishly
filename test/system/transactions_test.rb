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

  test "automatic account selection" do
    login_user(users(:transactions), 'SomePassword123^!')

    click_on "New Transaction"

    assert page.find("#transaction_account").value == "Current Account", format_error("Unexpected selected account", "Current Account", page.find("#transaction_account").value)
    click_on "Close"

    page.find("#account_16").click
    click_on "New Transaction"
    assert page.find("#transaction_account").value == "Current Account", format_error("Unexpected selected account", "Current Account", page.find("#transaction_account").value)
    click_on "Close"

    page.find("#account_17").click
    click_on "New Transaction"
    assert page.find("#transaction_account").value == "Savings Account", format_error("Unexpected selected account", "Savings Account", page.find("#transaction_account").value)
  end

  test "automatic currency selection" do
    login_user(users(:transactions), 'SomePassword123^!')

    click_on "New Transaction"
    assert page.find("#transaction_currency").value == "EUR", format_error("Unexpected selected currency", "EUR", page.find("#transaction_currency").value)

    select "JPY", from: "Account"
    assert page.find("#transaction_currency").value == "JPY", format_error("Unexpected selected currency", "JPY", page.find("#transaction_currency").value)

    select "CAD", from: "Currency"
    select "Current Account", from: "Account"
    assert page.find("#transaction_currency").value == "CAD", format_error("Unexpected selected currency", "CAD", page.find("#transaction_currency").value)
  end

  test "open category dropdown" do
    login_user(users(:transactions), 'SomePassword123^!')

    click_on "New Transaction"

    assert_selector '#categoriesDropdownOptions_', visible: :hidden
    page.find("#categories-dropdown").click
    assert_selector '#categoriesDropdownOptions_', visible: :visible
  end

  test "select category" do
    login_user(users(:bas), 'SomePassword123^!')

    click_on "New Transaction"

    assert_selector "#categories-dropdown", text: "Uncategorised"

    page.find("#categories-dropdown").click
    page.find(".category_11").click

    assert_selector "#categories-dropdown", text: "Cinema"
  end

  test "search category" do
    login_user(users(:bas), 'SomePassword123^!')

    click_on "New Transaction"

    assert_selector "#categories-dropdown", text: "Uncategorised"

    page.find("#categories-dropdown").click
    page.find("#search-categories_").fill_in with: "cinem"
    
    assert_selector ".category_1", visible: :visible
    assert_selector ".category_12", visible: :visible
    assert_selector ".category_11", visible: :visible

    for i in 1..82
        unless [1, 12, 11].include? i
            assert_selector ".category_" + i.to_s, visible: :hidden
        end
    end
  end

  test "simple transaction" do
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    create_transaction

    assert_selector "#transactions_list", text: "Today\n€0.00"
    assert_selector "#transactions_list", text: "test\n€0.00"
  end

  test "expense different currency" do
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    params = {
        currency: "JPY",
        amount: "100"
    }

    create_transaction(params)
    assert_selector "#transactions_list", text: "~ ¥-100"
    assert_selector "#transactions_list", text: "€-0.80"
  end

  test "simple income" do
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    params = {
        type: "income",
        amount: "100.85"
    }

    create_transaction(params)
    assert_selector "#transactions_list", text: "€100.85"
  end

  test "simple transfer" do
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    params = {
        type: "transfer",
        from_account: "Current Account",
        to_account: "Savings Account",
        amount: "500.05"
    }

    create_transaction(params)

    assert_selector "#transactions_list", text: "Today\n€0.00"
    assert_selector "#transactions_list", text: "€500.05"
    assert_selector "#transactions_list", text: "€-500.05"
    assert_selector "#transactions_list", text: "Transferred from Current Account"
    assert_selector "#transactions_list", text: "Transferred to Savings Account"
  end

  test "multiple transactions" do
    login_user(users(:transactions), 'SomePassword123^!')
    page.find("#account_0").click

    params = {
        multiple: "multiple",
        transactions: "one 100\ntwo 200\nthree 300\nfour 400",
    }

    create_transaction(params)
    sleep 1
    assert_selector "#transactions_list", text: "Today\n€-1,000.00"

    assert_selector ".child_transactions", visible: :hidden

    page.find(".show-child-transactions").click
    sleep 0.2

    assert_selector ".child_transactions", visible: :visible
    assert_selector "#transactions_list", text: "one"
    assert_selector "#transactions_list", text: "two"
    assert_selector "#transactions_list", text: "three"
    assert_selector "#transactions_list", text: "four"
    assert_selector "#transactions_list", text: "€-100.00"
    assert_selector "#transactions_list", text: "€-200.00"
    assert_selector "#transactions_list", text: "€-300.00"
    assert_selector "#transactions_list", text: "€-400.00"
  end

  def create_transaction(params={})
    params = create_params(params)
    
    while check_form(params) == false
        unless page.find("#transaction_description", visible: :all).visible?
            click_on "New Transaction"
        end
        fill_form(params)
    end

    click_on "Create Transaction"
    sleep 0.2
  end

  def create_params(custom_params={})
    params = {
        type: "expense",
        description: "test",
        account: "Current Account",
        from_account: "Current Account",
        to_account: "Current Account",
        category: 0,
        multiple: "single",
        amount: 0,
        transactions: "",
        currency: nil,
        date: nil,
        time: nil,
        rate: nil,
        amount_in_account_currency: nil,
        transfer_rate: nil,
        amount_in_transfer_currency: nil
    }

    custom_params.keys.each do |cp|
      params[cp] = custom_params[cp]
    end

    return params

  end

  def fill_form(params)
    unless page.find("#transaction_description", visible: :all).visible?
        click_on "New Transaction"
    end

    page.find("#type-" + params[:type]).click
    fill_in "Description", with: params[:description]
    select params[:account], from: "Account" unless params[:type] == "transfer"
    select params[:from_account], from: "From account" if params[:type] == "transfer"
    select params[:to_account], from: "To account" if params[:type] == "transfer"

    unless params[:type] == "transfer"
        page.find("#categories-dropdown").click
        page.find(".category_" + params[:category].to_s).click
        select params[:currency], from: "Currency" unless params[:currency].nil?
    end

    page.find("#multiple-" + params[:multiple]).click

    if params[:multiple] == "single"
        fill_in "Amount", with: params[:amount].to_s
    else
        fill_in "Transactions", with: params[:transactions]
    end

    fill_in "Date", with: params[:date] unless params[:date].nil?
    fill_in "Time", with: params[:time] unless params[:time].nil?
    fill_in "Rate", with: params[:rate] unless params[:rate].nil?
    page.find("#transaction_account_currency").fill_in with: params[:amount_in_account_currency] unless params[:amount_in_account_currency].nil?
    page.find("#transaction_rate_from_to").fill_in with: params[:transfer_rate] unless params[:transfer_rate].nil?
    page.find("#transaction_to_account_currency").fill_in with: params[:amount_in_transfer_currency] unless params[:amount_in_transfer_currency].nil?

    #take_screenshot
  end

  def check_form(params)
    unless page.find("#transaction_description", visible: :all).visible?
        click_on "New Transaction"
    end

    return false if page.find("#transaction_description").value != params[:description].to_s
    return false if page.find("#transaction_amount").value != params[:amount].to_s unless params[:multiple] == "multiple"
    return false if page.find("#transaction_transactions").value != params[:transactions].to_s unless params[:multiple] == "single"

    return true
  end

end