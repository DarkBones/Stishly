require "application_system_test_case"

class ChildTransactionsTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit child_transactions_url
  #
  #   assert_selector "h1", text: "ChildTransactions"
  # end

  test "child transactions invisible" do
    login_user(users(:transactions), 'SomePassword123^!')

    page.find("#account_0").click

    click_on "New Transaction"

    fill_in "Description", with: "Multiple transactions"
    page.find("#transactionform #multiple_multiple").click
    fill_in "Transactions", with: "one 1\r\ntwo 2\r\nthree 3\r\nfour 4\r\n"
    click_on "Create Transaction"
    sleep 2

    assert_selector '.child_transactions', visible: :hidden
    page.find('.show-child-transactions').click
    assert_selector '.child_transactions', visible: :visible

  end

end
