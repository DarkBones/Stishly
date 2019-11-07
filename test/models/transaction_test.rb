# == Schema Information
#
# Table name: transactions
#
#  id                       :bigint           not null, primary key
#  user_id                  :bigint
#  amount                   :integer
#  direction                :integer
#  description              :string(100)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :integer
#  timezone                 :string(255)
#  currency                 :string(255)
#  account_currency_amount  :integer
#  category_id              :bigint
#  parent_id                :bigint
#  local_datetime           :datetime
#  transfer_account_id      :bigint
#  user_currency_amount     :integer
#  transfer_transaction_id  :integer
#  scheduled_transaction_id :integer
#  is_scheduled             :boolean          default(FALSE)
#  schedule_id              :bigint
#  queue_scheduled          :boolean          default(FALSE)
#  is_queued                :boolean          default(FALSE)
#  schedule_period_id       :integer
#  is_cancelled             :boolean          default(FALSE)
#  scheduled_date           :date
#  is_balancer              :boolean          default(FALSE)
#  hash_id                  :string(255)
#  is_main                  :boolean
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  test "Create simple transaction" do
    current_user = users(:bas)

    params = create_params

    transaction = Transaction.create(params, current_user)
    assert transaction.persisted? == true, format_error("Not able to create transaction")
  end

  test "Amount conversion" do
    current_user = users(:bas)
    
    params = {
      type: "expense",
      amount: "10"
    }
    params = create_params(params)
    transaction = Transaction.create(params, current_user)
    assert transaction.amount == -1000, format_error("Unexpected transaction amount", "-1000", transaction.amount)

    params = {
      type: "expense",
      amount: "100",
      currency: "JPY"
    }
    params = create_params(params)
    transaction = Transaction.create(params, current_user)
    assert transaction.amount == -100, format_error("Unexpected transaction amount", "-100", transaction.amount)
  end

  test "Currency conversion" do
    current_user = users(:bas)
    params = {
      type: "expense",
      amount: "10000",
      currency: "JPY",
      rate: "0.008"
    }
    params = create_params(params)
    transaction = Transaction.create(params, current_user)
    assert transaction.account_currency_amount == -8000, format_error("Unexpected transaction amount", "-8000", transaction.account_currency_amount)
  end

  test "Multiple transactions" do
    current_user = users(:bas)

    params = {
      type: "expense",
      multiple: "multiple",
      transactions: "one 100\ntwo 200\nthree 300\nfour 400"
    }
    params = create_params(params)
    transaction = Transaction.create(params, current_user)

    assert transaction.children.length == 4, format_error("Unexpected transaction count", 4, transaction.children.length)
    assert transaction.amount == -100000, format_error("Unexpected main transaction amount", -100000, transaction.amount)

  end

  test "Transfer transaction" do
    current_user = users(:bas)
    from_account = accounts(:bas_1)
    to_account = accounts(:bas_2)

    params = {
      type: "transfer",
      amount: "1000",
      from_account: from_account.slug,
      to_account: to_account.slug
    }
    params = create_params(params)

    transaction = Transaction.create(params, current_user)
    assert_not transaction.transfer_transaction.nil?, format_error("No transfer transaction")

    assert transaction.account.id == from_account.id
    assert transaction.amount == -100000, format_error("Unexpected transaction amount", -100000, transaction.amount)
    assert transaction.direction == -1, format_error("Unexpected transaction direction", -1, transaction.direction)
    assert transaction.transfer_account_id == to_account.id, format_error("Unexpected transaction transfer account", to_account.id, transaction.transfer_account_id)

    assert transaction.transfer_transaction.amount == 100000, format_error("Unexpected transaction amount", 100000, transaction.transfer_transaction.amount)
    assert transaction.transfer_transaction.direction == 1, format_error("Unexpected transaction direction", 1, transaction.transfer_transaction.direction)
    assert transaction.transfer_transaction.transfer_account_id == from_account.id, format_error("Unexpected transaction transfer account", from_account.id, transaction.transfer_transaction.transfer_account_id)
  end

  test "Multi transfer transactions" do
    current_user = users(:bas)
    from_account = accounts(:bas_1)
    to_account = accounts(:bas_2)

    params = {
      type: "transfer",
      amount: "1000",
      from_account: from_account.slug,
      to_account: to_account.slug,
      multiple: "multiple",
      transactions: "one 100\ntwo 200\nthree 300\nfour 400"
    }
    params = create_params(params)

    transaction = Transaction.create(params, current_user)
    assert transaction.children.length == 4, format_error("Unexpected amount of transactions", 4, transaction.children.length)
    assert transaction.transfer_transaction.children.length == 4, format_error("Unexpected amount of transactions", 4, transaction.transfer_transaction.children.length)
  end

  test "transfer between accounts with different currencies" do
    current_user = users(:bas)
    from_account = accounts(:bas_JPY)
    to_account = accounts(:bas_EUR)

    params = {
      type: "transfer",
      amount: "100",
      description: "transfer between accounts with different currencies",
      from_account: from_account.slug,
      to_account: to_account.slug,
      rate_from_to: "0.008",
      account_currency: "JPY"
    }
    params = create_params(params)

    transaction = Transaction.create(params, current_user)
    assert transaction.amount == -100, format_error("Unexpected transaction amount", -100, transaction.amount)
    assert transaction.account_currency_amount == -100, format_error("Unexpected transaction account currency amount", -100, transaction.account_currency_amount)
    assert transaction.user_currency_amount == -80, format_error("Unexpected transaction user currency amount", -80, transaction.user_currency_amount)

    assert transaction.transfer_transaction.amount == 100, format_error("Unexpected transaction amount", 100, transaction.transfer_transaction.amount)
    assert transaction.transfer_transaction.account_currency_amount == 80, format_error("Unexpected transaction account currency amount", 80, transaction.transfer_transaction.account_currency_amount)
    assert transaction.transfer_transaction.user_currency_amount == 80, format_error("Unexpected transaction user currency amount", 80, transaction.transfer_transaction.user_currency_amount)

  end

  def create_params(customised_params={}, current_user=nil, account=nil)
    current_user ||= users(:bas)
    account ||= accounts(:bas_1)

    params = {
      :account => account.slug,
      :from_account => account.slug,
      :to_account => account.slug,
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
      :active_account => account.slug,
      :account_currency => "EUR",
      :to_account_currency => "EUR"
    }

    customised_params.keys.each do |cp|
      params[cp] = customised_params[cp]
    end

    return params
  end

end
