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
		assert_selector '#edit_transaction_form #rate_from_to', visible: :visible

		# verify the rate label is correctly formatted
		assert_selector '#edit_transaction_form #rate_from_to', text: 'Rate EUR to JPY'

		# click on expense
		find('#transactionform #type-expense').click

		sleep 1

		# verify the conversion rates are hidden
		assert_selector '#edit_transaction_form #rate_from_to', visible: :hidden

		# click on transfer
		find('#transactionform #type-transfer').click

		sleep 1

		# verify the conversion rates are visible
		assert_selector '#edit_transaction_form #rate_from_to', visible: :visible

		take_screenshot

	end

end