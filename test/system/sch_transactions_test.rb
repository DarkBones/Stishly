require "application_system_test_case"

class SchTransactionsTest < ApplicationSystemTestCase
  
  test "attach transactions to schedule" do 
    # login as schedules user
    login_user(users(:schedules), 'SomePassword123^!')

    page.find("#account_0").click

    page.find("#select_transaction_1801").click
    page.find("#select_transaction_1804").click
    page.find("#select_transaction_1806").click

    page.find("#mass_assign_to_schedule").click

    assert page.find("#schedules_transaction_transactions", visible: :all).value == "1801 1804 1806"

    #select "Payday", from: "Schedule"
    page.find("#schedules_transaction_schedules").select("Payday")

    click_on "Add"

    assert_selector "#flash_notice", text: "Added 3 transactions to Payday"
  end

  test "toggle edit scheduled transactions menu" do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find(".navbar-gear").click
    click_on "Schedules"

    page.find("#schedule-transactions-button_GFl1hng-oIiK").click
    wait_for_ajax

    assert_selector "#sch_transactions_list", text: "Test"
    assert_selector "#sch_transactions_list", text: "Main"
    assert_selector "#sch_transactions_list", text: "Transfer"
    assert_selector "#sch_transactions_list", text: "€10.90"
    assert_selector "#sch_transactions_list", text: "€10.00"
    assert_selector "#sch_transactions_list", text: "€500.00"

    assert_selector "#transaction_1001", visible: :hidden
    assert_selector "#transaction_1002", visible: :hidden
    assert_selector "#transaction_1003", visible: :hidden

    page.find("#heading1001").click
    sleep 0.3
    assert_selector "#transaction_1001", visible: :visible
    assert_selector "#transaction_1002", visible: :hidden
    assert_selector "#transaction_1003", visible: :hidden

    page.find("#heading1002").click
    sleep 0.3
    assert_selector "#transaction_1001", visible: :hidden
    assert_selector "#transaction_1002", visible: :visible
    assert_selector "#transaction_1003", visible: :hidden

    page.find("#heading1003").click
    sleep 0.3
    assert_selector "#transaction_1001", visible: :hidden
    assert_selector "#transaction_1002", visible: :hidden
    assert_selector "#transaction_1003", visible: :visible
  end

  test "edit scheduled transactions" do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find(".navbar-gear").click
    click_on "Schedules"

    page.find("#schedule-transactions-button_GFl1hng-oIiK").click
    wait_for_ajax

    page.find("#heading1001").click
    sleep 0.3

    fill_in "Description", with: "New description"
    click_on "Save"
    wait_for_ajax

    assert_selector "#sch_transactions_list", text: "New description"
  end
end
