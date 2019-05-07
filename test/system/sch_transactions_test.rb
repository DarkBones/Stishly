require "application_system_test_case"

class SchTransactionsTest < ApplicationSystemTestCase
  
  test "attach transactions to schedule" do 
    # login as schedules user
    login_user(users(:schedules), 'SomePassword123^!')

    page.find("#account_0").click
    
    page.find("#select_801").click
    page.find("#select_804").click
    page.find("#select_806").click

    click_on "assign to schedule"

    assert page.find("#sch_transactions_schedule_transactions", visible: false).value == "801 804 806"

    #select "Payday", from: "Schedule"
    page.find("#sch_transactions_schedule_schedules").select("Payday")

    click_on "Add"

    assert_selector "#flash_notice", text: "Added 3 transactions to Payday"
  end

  test "toggle edit scheduled transactions menu" do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find(".navbar-gear").click
    click_on "Schedules"

    page.find("#schedule-transactions-button_2").click
    wait_for_ajax

    assert_selector "#sch_transactions_list", text: "Test"
    assert_selector "#sch_transactions_list", text: "Main"
    assert_selector "#sch_transactions_list", text: "Transfer"
    assert_selector "#sch_transactions_list", text: "€10.90"
    assert_selector "#sch_transactions_list", text: "€10.00"
    assert_selector "#sch_transactions_list", text: "€500.00"

    assert_selector "#edit_sch_transaction_1", visible: :hidden
    assert_selector "#edit_sch_transaction_2", visible: :hidden
    assert_selector "#edit_sch_transaction_3", visible: :hidden

    page.find("#heading1").click
    sleep 0.3
    assert_selector "#edit_sch_transaction_1", visible: :visible
    assert_selector "#edit_sch_transaction_2", visible: :hidden
    assert_selector "#edit_sch_transaction_3", visible: :hidden

    page.find("#heading2").click
    sleep 0.3
    assert_selector "#edit_sch_transaction_1", visible: :hidden
    assert_selector "#edit_sch_transaction_2", visible: :visible
    assert_selector "#edit_sch_transaction_3", visible: :hidden

    page.find("#heading3").click
    sleep 0.3
    assert_selector "#edit_sch_transaction_1", visible: :hidden
    assert_selector "#edit_sch_transaction_2", visible: :hidden
    assert_selector "#edit_sch_transaction_3", visible: :visible
  end

  test "edit scheduled transactions" do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find(".navbar-gear").click
    click_on "Schedules"

    page.find("#schedule-transactions-button_2").click
    wait_for_ajax

    page.find("#heading1").click
    sleep 0.3

    fill_in "Description", with: "New description"
    click_on "Save"
    wait_for_ajax

    page.find("#schedule-transactions-button_2").click
    wait_for_ajax

    assert_selector "#sch_transactions_list", text: "New description"
  end

end
