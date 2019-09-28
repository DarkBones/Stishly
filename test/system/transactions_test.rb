require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase

	test 'single expense transaction' do

		params = {
			description: 'Simple expense',
			amount: 100
		}

		start

		create_transaction(params)

		# verify the day total is visible
		assert_selector "#transactions_list h3#day_#{Time.now.strftime("%Y-%m-%d")}", text: Time.now.strftime("%d/%m/%Y")
		assert_selector "#transactions_list h3#day_#{Time.now.strftime("%Y-%m-%d")}", text: '€-100.00'

		# verify the transaction is visible
		assert_selector '#transactions_list', text: 'Simple expense'
		assert_selector '#transactions_list', text: '€-100.00'

		# verify the account balance was updated
		assert_selector '#accounts_list', text: '€9,900.00'

		# create another transaction
		create_transaction(params)

		# verify the day total was updated
		assert_selector "#transactions_list h3#day_#{Time.now.strftime("%Y-%m-%d")}", text: '€-200.00'

		# verify the account balance was updated
		assert_selector '#accounts_list', text: '€9,800.00'

		# verify a new account history was recorded
		account = Account.where(user_id: 8, name: 'Current Account').take
		history = AccountHistory.where(account_id: account.id, balance: 980000).take
		assert_not history.nil?, "No account history recorded"

	end

	test 'all months' do

		start

		# create a transaction for every month of the year 2015 and check if the date was handled correctly
		['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].each_with_index do |m, i|
			params = {
				description: "Transaction #{m}",
				amount: 100,
				date: "01-#{m}-2015"
			}

			create_transaction(params)

			if (i+1) < 10
				n = '0' + (i+1).to_s
			else
				n = (i+1).to_s
			end

			assert_selector "#transactions_list h3#day_2015-#{n}-01", text: '€-100.00'
			assert_selector "#transactions_list h3#day_2015-#{n}-01", text: "01/#{n}/2015"
		end

		# create a transaction with blank date and check if today's date was used
		params = {
			description: "Blank date",
			amount: 200,
			date: ""
		}

		fill_form(params)
		# verify that the date field is blank
		assert find('#transactionform #transaction_date').value == ''
		click_on I18n.t('buttons.create_transaction.text')
		sleep 1

		# verify that it defaulted to today's date
		assert_selector "#transactions_list h3#day_#{Time.now.strftime("%Y-%m-%d")}", text: Time.now.strftime("%d/%m/%Y")
		assert_selector "#transactions_list h3#day_#{Time.now.strftime("%Y-%m-%d")}", text: '€-200.00'

	end

	test 'expense different currency' do

		params = {
			description: 'Expense different currency',
			amount: 10000,
			currency: 'JPY'
		}

		start

		create_transaction(params)

		assert_selector '#transactions_list', text: '~ ¥-10,000'
		assert_selector '#transactions_list', text: '€-80.00'

	end

	test 'income different currency' do

		params = {
			type: 'income',
			description: 'Expense different currency',
			amount: 10000,
			currency: 'JPY'
		}

		start

		create_transaction(params)

		assert_selector '#transactions_list', text: '~ ¥10,000'
		assert_selector '#transactions_list', text: '€80.00'

	end
	
	test 'transfer transaction same currency' do

		params = {
			type: 'transfer',
			description: 'Transfer same currency',
			from_account: 'Current Account',
			to_account: 'Savings Account',
			amount: 1000
		}

		start

		create_transaction(params)

		# verify the transactions are in the list
		assert_selector '#transactions_list', text: '€-1,000.00'
		assert_selector '#transactions_list', text: '€1,000.00'

		# verify the transfer message
		assert_selector '#transactions_list', text: 'Transferred from Current Account'
		assert_selector '#transactions_list', text: 'Transferred to Savings Account'

		# verify the account balances
		assert_selector '#accounts_list', text: '€9,000.00'
		assert_selector '#accounts_list', text: '€1,000.00'

	end

	test 'transfer transaction different currency' do

		params = {
			type: 'transfer',
			description: 'Transfer different currency',
			from_account: 'Current Account',
			to_account: 'JPY Account',
			amount: 1000
		}

		start

		create_transaction(params)

		# verify the transactions are in the list
		assert_selector '#transactions_list', text: '€-1,000.00'
		assert_selector '#transactions_list', text: '€1,000.00'

		# verify the transfer message
		assert_selector '#transactions_list', text: 'Transferred from Current Account'
		assert_selector '#transactions_list', text: 'Transferred to JPY Account'

		# verify the account balances
		assert_selector '#accounts_list', text: '€9,000.00'
		assert_selector '#accounts_list', text: '¥124,460'

		visit '/accounts/JPY Account'

		assert_selector '#transactions_list', text: 'Transferred from Current Account'
		assert_selector '#transactions_list', text: '~ €1,000.00'
		assert_selector '#transactions_list', text: '¥124,460'

	end
	
	test 'multiple transfer transaction different currency' do

		params = {
			type: 'transfer',
			description: 'Transfer different currency',
			from_account: 'Current Account',
			to_account: 'JPY Account',
			multiple: 'multiple',
			transactions: "one 100\ntwo 200\nthree 300\nfour 400"
		}

		start

		create_transaction(params)

		all('.show-child-transactions')[1].click
		all('.show-child-transactions')[0].click

		sleep 0.2
		
		assert_selector '#transactions_list', text: '€-1,000.00'
		assert_selector '#transactions_list', text: '€-100.00'
		assert_selector '#transactions_list', text: '€-200.00'
		assert_selector '#transactions_list', text: '€-300.00'
		assert_selector '#transactions_list', text: '€-400.00'

		assert_selector '#transactions_list', text: '€1,000.00'
		assert_selector '#transactions_list', text: '€100.00'
		assert_selector '#transactions_list', text: '€200.00'
		assert_selector '#transactions_list', text: '€300.00'
		assert_selector '#transactions_list', text: '€400.00'

		visit '/accounts/JPY Account'

		find('.show-child-transactions').click

		sleep 0.2

		assert_selector '#transactions_list', text: '~ €1,000.00'
		assert_selector '#transactions_list', text: '¥124,460'
		assert_selector '#transactions_list', text: '€100.00'
		assert_selector '#transactions_list', text: '€200.00'
		assert_selector '#transactions_list', text: '€300.00'
		assert_selector '#transactions_list', text: '€400.00'

	end

	# test hidden child transactions
	test 'hidden child transactions' do

		params = {
			description: 'Multiple transactions',
			multiple: 'multiple',
			transactions: "one 100\ntwo 200\nthree 300\nfour 400"
		}

		start

		create_transaction(params)

		assert_selector '.child_transactions', visible: :hidden

		find('.show-child-transactions').click

		assert_selector '.child_transactions', visible: :visible

	end

	# test future date and verify the transaction is not visible
	test 'future date' do

		params = {
			description: 'Future transaction',
			amount: 100,
			date: 1.week.from_now.strftime("%d-%b-%Y")
		}

		start

		create_transaction(params)

		transaction = Transaction.where(user_id: 8, description: 'Future transaction').take

		assert_no_selector "#transactions_list #transaction_#{transaction.hash_id}"

		assert_not transaction.scheduled_date.nil?

		page.driver.browser.navigate.refresh

		assert_no_selector "#transactions_list #transaction_#{transaction.hash_id}"

	end


	def create_transaction(params)
		fill_form(params)
		click_on I18n.t('buttons.create_transaction.text')
		sleep 1
	end

	def fill_form(params)
		# click on new transaction
		click_on I18n.t('buttons.new_transaction.text')

		# select the transaction type
		find("#transactionform #type-#{params[:type]}").click unless params[:type].nil?

		# fill in the description
		find('#transactionform #transaction_description').set(params[:description]) unless params[:description].nil?

		# select the account(s)
		find('#transactionform #transaction_account').find(:option, params[:account]).select_option unless params[:account].nil?
		find('#transactionform #transaction_from_account').find(:option, params[:from_account]).select_option unless params[:from_account].nil?
		find('#transactionform #transaction_to_account').find(:option, params[:to_account]).select_option unless params[:to_account].nil?

		# select currency
		find('#transactionform #transaction_currency').find(:option, params[:currency]).select_option unless params[:currency].nil?

		# select category
		unless params[:category].nil?
			category = Category.where(user_id: 8, name: params[:category]).take
			find('#transactionform #categories-dropdown').click
			find(".category_#{category.hash_id}").click
		end

		# select multiple / single
		find("#transactionform #multiple-#{params[:multiple]}").click unless params[:multiple].nil?

		# fill in the amount
		find('#transactionform #transaction_amount').set(params[:amount]) unless params[:amount].nil?

		# fill in the transactions
		find('#transactionform #transaction_transactions').set(params[:transactions]) unless params[:transactions].nil?

		# fill in the date and time
		find('#transactionform #transaction_date').set(params[:date]) unless params[:date].nil?
		find('#transactionform #transaction_time').set(params[:time]) unless params[:time].nil?
	end

	def start
		login_user(users(:transactions), 'SomePassword123^!')
		visit '/accounts'
	end

end