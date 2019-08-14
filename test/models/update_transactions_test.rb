require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  test "get main transaction" do
  	user = users(:update_transactions)
  	transaction = user.transactions.find(1180403)
  	
  	transaction = Transaction.find_main_transaction(transaction)
  	
  	assert transaction.id == 11803, format_error("Unexpected transaction", 11803, transaction.id)
  end

  test "update transaction" do
    user = users(:update_transactions)
    transaction = transactions(:update_transaction_simple_expense)

    params = create_params
    params[:multiple] = "multiple"
    params[:transactions] = "one 1\ntwo 2\nthree 3\nfour 4"
    params[:type] = "transfer"
    params[:to_account] = "Two"

    new_transaction = Transaction.update(transaction, params, user)
    assert new_transaction.id == transaction.id, format_error("Unexpected transaction id", transaction.id, new_transaction.id)
    
  end

  test "update to single expense" do
  	user = users(:update_transactions)
  	
  	params = create_params

		assert_transactions(params, user)
  end

  test "update to multiple expense" do
  	user = users(:update_transactions)

  	params = create_params
  	params[:multiple] = "multiple"
  	params[:transactions] = "one 1\ntwo 2\nthree 3\nfour 4"

  	assert_transactions(params, user)
  end

  test "update to single transfer" do
  	user = users(:update_transactions)

  	params = create_params
  	params[:type] = "transfer"
    params[:to_account] = "Two"

  	assert_transactions(params, user)
  end

  test "update to multiple transfer" do
  	user = users(:update_transactions)

  	params = create_params
  	params[:type] = "transfer"
  	params[:multiple] = "multiple"
  	params[:transactions] = "one 1\ntwo 2\nthree 3\nfour 4"
    params[:to_account] = "Two"

  	assert_transactions(params, user)
  end

  def assert_transactions(params, user)
  	original_transactions = user.transactions

  	updated_transactions = []
  	user.transactions.where(parent_id: nil).each do |transaction|
  		if transaction.transfer_transaction_id.nil? || (!transaction.transfer_transaction_id.nil? && transaction.direction == -1)
  			updated_transactions.push(Transaction.find_main_transaction(Transaction.update(transaction, params, user)))
  		end
  	end

  	new_transaction = Transaction.find_main_transaction(Transaction.create(params, user))

  	updated_transactions.each do |ut|
  		ut.attributes.each do |field, value|
  			if field != "created_at" && field != "updated_at"
  				if field == "id"
  					assert_not original_transactions.find(value).nil?, format_error("Unexpected transaction id. When a transaction is updated, is should keep the same id", nil, ut.id)
  				elsif field != "transfer_transaction_id"
  					assert new_transaction.attributes[field] == value, format_error("Unexpected #{field}", new_transaction.attributes[field], value)
  				end
  			end
  		end

  		assert ut.transfer_transaction.nil? == new_transaction.transfer_transaction.nil?, format_error("Unexpected transfer transaction", new_transaction.transfer_transaction.nil?, ut.transfer_transaction.nil?)
  		assert ut.children.length == new_transaction.children.length, format_error("Unexpected children amount", new_transaction.children.length, ut.children.length)
  	end
  end

  def create_params(customised_params={}, current_user=nil, account=nil)
    current_user ||= users(:bas)
    account ||= accounts(:bas_1)

    params = {
      :account => "One",
      :from_account => "One",
      :to_account => "One",
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
      :active_account => "One",
      :account_currency => "EUR",
      :to_account_currency => "EUR"
    }

    customised_params.keys.each do |cp|
      params[cp] = customised_params[cp]
    end

    return params
  end

end