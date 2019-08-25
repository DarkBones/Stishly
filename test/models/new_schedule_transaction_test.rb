require 'test_helper'

class NewScheduleTransactionTest < ActiveSupport::TestCase

  test "new simple transaction" do
    current_user = users(:bas)

    params = create_params

    transaction = Transaction.create(params, current_user)
    assert transaction.persisted? == true, format_error("Not able to create transaction")
    assert transaction.schedules[0].id == 101, format_error("Transaction not linked to schedule")
  end

  test "new multiple transactions" do
    current_user = users(:bas)

    params = {
      amount: "1000",
      multiple: "multiple",
      transactions: "one 100\ntwo 200\nthree 300\nfour 400"
    }
    params = create_params(params)

    transactions = Transaction.create(params, current_user)
    assert transactions.children.length == 4, format_error("Unexpected amount of transactions", 4, transactions.children.length)
  end

  def create_params(customised_params={}, current_user=nil, account=nil)
    current_user ||= users(:bas)
    account ||= accounts(:bas_1)

    params = {
      :account => account.name,
      :from_account => account.name,
      :to_account => account.name,
      :multiple => "single",
      :timezone => "Europe/London",
      :category_id => "0",
      :currency => "EUR",
      :date => "25-Mar-2019",
      :time => "12:00 PM",
      :rate_from_to => "1",
      :rate => "1",
      :type => "Expense",
      :description => "test",
      :amount => "10",
      :transactions => "",
      :active_account => account.name,
      :account_currency => "EUR",
      :to_account_currency => "EUR",
      :schedule_id => "101"
    }

    customised_params.keys.each do |cp|
      params[cp] = customised_params[cp]
    end

    return params
  end

end