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

    assert_not account.is_a?(ActiveRecord::Base), format_error("Created account with dots in name")
    assert account == I18n.t('account.failure.invalid_name_dot'), format_error("Unexpected error", I18n.t('account.failure.invalid_name_dot'), account)
  end

  test "Save account without balance" do
    current_user = users(:bas)
    account = current_user.accounts.build({:name => 'test account'})

    assert account.save, format_error("Could not save account without specifying the balance")
    assert account.balance == 0, format_error("Unexpected default account balance", 0, account.balance)
  end

  test "Create duplicate account" do
    current_user = users(:bas)
    params = {account_string: 'from_string account 9.99'}

    a1 = Account.create({:name => 'test duplicate'}, current_user)
    a2 = Account.create({:name => 'test duplicate'}, current_user)

    assert_not a2.is_a?(ActiveRecord::Base), format_error("Created duplicate account name")
    assert a2 == I18n.t('account.failure.already_exists'), format_error("Unexpected error", I18n.t('account.failure.already_exists'), a2)
  end
end
