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

    click_on "Add"

    assert_selector "#flash_notice", text: "Successfully added 3 transactions to Payday"
  end

end
