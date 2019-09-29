require "application_system_test_case"

class EditTransactionMenuTest < ApplicationSystemTestCase

	test 'transfer transaction in different currency' do

		params = {
			type: 'transfer',
			description: 'Transfer different currency',
			from_account: 'Current Account',
			to_account: 'JPY Account',
			amount: 1000
		}

		start_transaction

		create_transaction(params)

		# search the transaction in the database
		transaction = Transaction.where(user_id: 8, description: 'Transfer different currency', direction: -1).take

		# click on the transaction
		find("#txn_#{transaction.hash_id}").click

		sleep 1

		# verify the conversion rates are visible
		assert_selector '#edit_transactionform #rate_from_to', visible: :visible

		# verify the rate label is correctly formatted
		assert_selector '#edit_transactionform #rate_from_to', text: 'Rate EUR to JPY'

		# click on expense
		find('#edit_transactionform #type-expense').click

		sleep 1

		# verify the conversion rates are hidden
		assert_selector '#edit_transactionform #rate_from_to', visible: :hidden

		# click on transfer
		find('#edit_transactionform #type-transfer').click

		sleep 1

		# verify the conversion rates are visible
		assert_selector '#edit_transactionform #rate_from_to', visible: :visible

	end

	test 'edit transaction after ajax insert' do

		params = {
			description: 'Edit after ajax',
			amount: 1000,
			time: 1.hour.ago
		}

		start_transaction

		create_transaction(params)

		# search the transaction in the database
		transaction = Transaction.where(user_id: 8, description: 'Edit after ajax').take

		find("#txn_#{transaction.hash_id}").click
		sleep 1

		# verify the timezone field is filled in
		assert find('#edit_transactionform #timezone_input', visible: :all).value == transaction.timezone

		# verify the time is the same as the transaction time
		assert find('#edit_transactionform #transaction_time').value == transaction.local_datetime.strftime("%H:%M")

	end

end