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
  test "Save account without name" do
    current_user = User.find(1)
    account = current_user.accounts.build({:balance => 200})
    assert_not account.save, "Saved the account without a name"
  end

  test "Save account without balance" do
    current_user = User.find(1)
    account = current_user.accounts.build({:name => 'test account'})
    assert account.save, "Could not save account without specifying the balance"
    assert account.balance == 0, "Unexpected default account balance\nexpected:\t0\nactual:\t\t#{account.balance}"
  end

  test "Account creation" do
    current_user = User.find(1)

    params = {account_string: 'test account 9.99'}

    a1 = Account.create_from_string(params, current_user)
    duplicate_account = Account.create_from_string(params, current_user)

    params = {account_string: 'new test account'}
    a2 = Account.create_from_string(params, current_user)

    params = {account_string: ''}
    empty_string_account = Account.create_from_string(params, current_user)

    # check if accounts were created as expected
    assert_not a1.respond_to?(:to_str), "Could not create account"
    assert duplicate_account == 'Account already exists', "Created duplicate account"
    assert_not a2.respond_to?(:to_str), "Could not create account without specifying balance"
    assert empty_string_account == 'Please enter a valid account name', "Created account without name"

    # check account balances
    assert a1.balance == 999, "Unexpected account balance\nexpected:\t999\nactual:\t\t#{a1.balance}"
    assert a2.balance == 0, "Unexpected account balance\nexpected:\t0\nactual:\t\t#{a2.balance}"

    # check account currency
    assert_not a1.currency, "Unexpected account currency\nexpected:\t''\nactual:\t\t#{a1.currency}"
    assert_not a2.currency, "Unexpected account currency\nexpected:\t''\nactual:\t\t#{a2.currency}"

    # change currency
    a1 = Account.change_setting(a1, {setting_value: {currency: 'CAD'}}, current_user)

    # check if currency changed
    assert SettingValue.get_setting(a1, 'currency').value == 'CAD', "Unexpected account currency\nexpected:\tCAD\nactual:\t\t#{a1.currency}"
    
    # check if balance was converted
    assert a1.balance != 999, "Unexpected account balance after converting currency\nexpected:\t!999\nactual:\t\t#{a1.balance}"
  end
end
