require "application_system_test_case"

class ChildTransactionsTest < ApplicationSystemTestCase

  test "child transactions invisible" do
    login_user(users(:transactions), 'SomePassword123^!')

    page.find("#account_0").click

    click_on "New Transaction"

    fill_in "Description", with: "Multiple transactions"
    page.find("#transactionform #multiple-multiple").click
    fill_in "Transactions", with: "one 1\ntwo 2\nthree 3\nfour 4\n"
    find(:css, "input[id$='timezone_input']").set("Europe/London")
    click_on "Create Transaction"
    sleep 2

    assert_selector '.child_transactions', visible: :hidden
    page.find('.show-child-transactions').click
    assert_selector '.child_transactions', visible: :visible

  end

end
