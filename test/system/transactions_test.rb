require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  test "view transactions in account" do
    """
    Log in and view the accounts on the left menu
    Expected result:
    - See transactions belonging to the account
    """

    login_user(users(:bas), "SomePassword123^!")

    accounts = page.find("#accounts_list").all("li")

    for i in 1..5
      account = accounts("bas_#{i}")
      visit "/account/#{URI.encode(account.name)}"

      total = ((i * (i + 1)) / 2)

      assert_selector "#day_#{Time.now.strftime("%Y-%m-%d").to_s}", text: Time.now.strftime("%d %b %Y").to_s + "\n€ " + total.to_s + ".00"

      for x in 1..i
        assert_selector "#transactions_#{Time.now.strftime("%Y-%m-%d").to_s}", text: "transaction #{x}\n€ #{x}.00"
      end
    end

    #take_screenshot
  end

  test "Create transactions" do
    """
    Log in and create a new transactions from string
    Expected result:
    - New transactions show in the account view
    - Account balance is updated
    """

    login_user(users(:transactions_test), "SomePassword123^!")
    visit "/account/#{URI.encode("Test account")}"

    fill_in "quick-transaction-input", with: "payday +2060"
    select "EUR", from: "transaction[currency]"
    click_on "Create"

    assert_selector "#transactions_#{Time.now.strftime("%Y-%m-%d").to_s}", text: "payday\n€ 2,060.00"

    take_screenshot

  end
end
