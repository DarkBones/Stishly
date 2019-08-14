require 'test_helper'

class UpcomingTransactionsTest < ActiveSupport::TestCase

	test "create future transaction" do
		user = users(:future_transactions)

		params = create_params

		params[:date] = 1.week.from_now.strftime("%d-%b-%Y")
		transaction = Transaction.create(params, user)[0]

		assert transaction.is_scheduled == true, format_error("Future transactions should be scheduled")
		assert transaction.scheduled_date == 1.week.from_now.to_date, format_error("Unexpected scheduled date", 1.week.from_now.to_date, transaction.scheduled_date)

	end

	test "create past transaction" do
		user = users(:future_transactions)

		params = create_params

		params[:date] = 1.week.ago.strftime("%d-%b-%Y")
		transaction = Transaction.create(params, user)[0]

		assert transaction.is_scheduled == false, format_error("Past transactions should not be scheduled")
		assert transaction.scheduled_date.nil?, format_error("Unexpected scheduled date", "nil", transaction.scheduled_date)
	end

	test "create present transaction" do
		user = users(:future_transactions)

		params = create_params

		params[:date] = Time.now.strftime("%d-%b-%Y")
		transaction = Transaction.create(params, user)[0]

		assert transaction.is_scheduled == false, format_error("Present transactions should not be scheduled")
		assert transaction.scheduled_date.nil?, format_error("Unexpected scheduled date", "nil", transaction.scheduled_date)
	end

	test "run future transactions" do
		user = users(:future_transactions)

		transactions = Schedule.run_scheduled_transactions(user.transactions)
		
		assert transactions.length == 1, format_error("Unexpected transactions", 1, transactions.length)
		assert transactions[0].description == "future", format_error("Unexpected transaction description", "future", transactions[0].description)
		assert transactions[0].is_scheduled == false
		assert transactions[0].scheduled_date.nil?
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