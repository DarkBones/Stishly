require "application_system_test_case"

class SchTransactionsTest < ApplicationSystemTestCase
  test "attach transactions to schedule" do 
    # login as schedules user
    login_user(users(:schedules), 'SomePassword123^!')

    page.find("#account_0").click

    page.find("#select_transaction_5jGb4q5OIy2l").click
    page.find("#select_transaction_5mzqUy-0WyC4").click
    page.find("#select_transaction_91PqMe82hH36").click

    page.find("#mass_assign_to_schedule").click

    assert page.find("#schedules_transaction_transactions", visible: :all).value == "5jGb4q5OIy2l 5mzqUy-0WyC4 91PqMe82hH36"

    #select "Payday", from: "Schedule"
    page.find("#schedules_transaction_schedules").select("Payday")

    click_on "Add"

    assert_selector "#flash_notice", text: "Added 3 transactions to Payday"
  end

  test "toggle edit scheduled transactions menu" do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find(".navbar-gear").click
    click_on "Schedules"

    page.find("#schedule-transactions-button_GFl1hng-oIiK", visible: :all).click
    wait_for_ajax

    assert_selector "#sch_transactions_list", text: "Test"
    assert_selector "#sch_transactions_list", text: "Main"
    assert_selector "#sch_transactions_list", text: "Transfer"
    assert_selector "#sch_transactions_list", text: "€10.90"
    assert_selector "#sch_transactions_list", text: "€10.00"
    assert_selector "#sch_transactions_list", text: "€500.00"

    assert_selector "#transaction_48bPA_TS4aFb", visible: :hidden
    assert_selector "#transaction_OuzsEKnOk96x", visible: :hidden
    assert_selector "#transaction_1BOJK9aKnJD1", visible: :hidden

    page.find("#heading48bPA_TS4aFb").click
    sleep 0.3
    assert_selector "#transaction_48bPA_TS4aFb", visible: :visible
    assert_selector "#transaction_OuzsEKnOk96x", visible: :hidden
    assert_selector "#transaction_1BOJK9aKnJD1", visible: :hidden

    page.find("#headingOuzsEKnOk96x").click
    sleep 0.3
    assert_selector "#transaction_48bPA_TS4aFb", visible: :hidden
    assert_selector "#transaction_OuzsEKnOk96x", visible: :visible
    assert_selector "#transaction_1BOJK9aKnJD1", visible: :hidden

    page.find("#heading1BOJK9aKnJD1").click
    sleep 0.3
    assert_selector "#transaction_48bPA_TS4aFb", visible: :hidden
    assert_selector "#transaction_OuzsEKnOk96x", visible: :hidden
    assert_selector "#transaction_1BOJK9aKnJD1", visible: :visible
  end

  test "edit scheduled transactions" do
    login_user(users(:schedules), 'SomePassword123^!')

    page.find(".navbar-gear").click
    click_on "Schedules"

    page.find("#schedule-transactions-button_GFl1hng-oIiK", visible: :all).click
    wait_for_ajax

    page.find("#heading48bPA_TS4aFb").click
    sleep 0.3

    fill_in "Description", with: "New description"
    click_on "Save"
    wait_for_ajax

    assert_selector "#sch_transactions_list", text: "New description"
  end
end
