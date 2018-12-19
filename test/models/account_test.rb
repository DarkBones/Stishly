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

    assert accounts[:accounts].length == 5, format_error("Unexpected number of accounts", 5, accounts[:accounts].length)
    assert accounts[:total_balance] == 200, format_error("Unexpected total balance", 200, accounts[:total_balance])
  end
    
  test "Save account without name" do
    current_user = users(:bas)
    account = current_user.accounts.build({:balance => 200})

    assert_not account.save, format_error("Saved the account without a name")
  end

  test "Save account without balance" do
    current_user = users(:bas)
    account = current_user.accounts.build({:name => 'test account'})

    assert account.save, format_error("Could not save account without specifying the balance")
    assert account.balance == 0, format_error("Unexpected default account balance", 0, account.balance)
  end

  test "Create from string \"from_string account 9.99\"" do
    current_user = users(:bas)
    params = {account_string: 'from_string account 9.99'}

    a1 = Account.create_from_string(params, current_user)

    assert a1.is_a?(ActiveRecord::Base), format_error("Could not create account from string", result: a1)
    assert a1.balance == 999, format_error("Unexpected account balance", 999, a1.balance)
  end

  test "Create twice from string \"from_string account 9.99\"" do
    current_user = users(:bas)
    params = {account_string: 'from_string account 9.99'}

    a1 = Account.create_from_string(params, current_user)
    a2 = Account.create_from_string(params, current_user)
    
    assert_not a2.is_a?(ActiveRecord::Base), format_error("Created duplicate account name")
  end

  test "Create from string \"from_string account\"" do
    current_user = users(:bas)
    params = {account_string: 'from_string account'}

    a1 = Account.create_from_string(params, current_user)

    assert a1.is_a?(ActiveRecord::Base), format_error("Could not create account from string without specifying the balance", result: a1)
  end

  test "Convert currency" do
    # get the user
    current_user = users(:currency_test)

    # parameters for changing account's currency setting
    params = {setting_value: {currency: "JPY"}}
    account = accounts(:currency_1)

    # change account's currency setting
    a1 = Account.change_setting(account, params, current_user)

    # assert currency has changed to "JPY"
    currency = Account.get_currency(a1.id, current_user)
    assert currency == "JPY", format_error("Unexpected account currency after updating setting", "JPY", currency)

    # assert that the transactions that were made today have been converted to the new currency, and transactions that happened earlier were not updated
    a1.transactions.each do |t|
      puts t.created_at
    end
  end
end
