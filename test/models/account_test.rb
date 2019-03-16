# == Schema Information
#
# Table name: accounts
#
#  id          :bigint(8)        not null, primary key
#  balance     :integer
#  currency_id :bigint(8)
#  user_id     :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#  description :string(255)
#  position    :integer
#  currency    :string(255)
#  is_default  :boolean
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "Get accounts" do
    current_user = users(:bas)
    accounts = Account.get_accounts(current_user)

    assert accounts.length == 6, format_error("Unexpected number of accounts", 6, accounts.length)
    assert accounts.first.balance == 200, format_error("Unexpected total balance", 200, accounts.first.balance)
  end
    
  test "Save account without name" do
    current_user = users(:bas)
    account = current_user.accounts.build({:balance => 200})

    assert_not account.save, format_error("Saved the account without a name")
  end

  test "Save with dots in name" do
    current_user = users(:bas)
    account = Account.create_new({:name => 'test.dot.', :currency => 'EUR'}, current_user)
    
    assert_not account.name == "test.dot.", format_error("Created account with dots in name")
  end

  test "Save account without balance" do
    current_user = users(:bas)
    account = current_user.accounts.build({:name => 'test account'})

    assert account.save, format_error("Could not save account without specifying the balance")
    assert account.balance == 0, format_error("Unexpected default account balance", 0, account.balance)
  end

  test "Create duplicate account" do
    current_user = users(:bas)

    a1 = Account.create({:name => 'test duplicate'}, current_user)
    a2 = Account.create({:name => 'test duplicate'}, current_user)

    assert_not a2.is_a?(ActiveRecord::Base), format_error("Created duplicate account name")
    assert a2 == I18n.t('account.failure.already_exists'), format_error("Unexpected error", I18n.t('account.failure.already_exists'), a2)
  end

  test "Create new account" do
    current_user = users(:bas)
    params = {name: 'New account', balance: 500, currency: 'EUR', description: 'Test description'}

    account = Account.create_new(params, current_user)

    assert account.name == 'New account', format_error("Unexpected account name", 'New account', account.name)
    assert account.balance == 50000, format_error("Unexpected account balance", 50000, account.balance)
    assert account.currency == 'EUR', format_error('Unexpected account currency', 'EUR', account.currency)
    assert account.description == 'Test description', format_error('Unexpected account description', 'Test description', account.description)
  end

  test "Get currency" do
    current_user = users(:bas)
    account = current_user.accounts.first

    currency = Account.get_currency(account)
    assert currency.is_a?(Money::Currency), format_error('Unexpected currency class', 'Money::Currency', currency.class.name)
  end
end
