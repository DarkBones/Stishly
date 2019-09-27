require "application_system_test_case"

class TransactionMenuTest < ApplicationSystemTestCase
=begin
	test 'open and close transaction menu' do

		login_user(users(:transactions), 'SomePassword123^!')

		# verify that the new transaction form is hidden
		assert_selector '#transactionform', visible: :hidden

		# click on new transaction
		click_on I18n.t('buttons.new_transaction.text')

		# verify the form is visible
		assert_selector '#transactionform', visible: :visible

		# click on close
		click_on I18n.t('buttons.close.text')

		# verify the form is hidden again
		assert_selector '#transactionform', visible: :hidden

	end

	test 'type color changes' do

		start

		# verify the color is red
		assert_selector '#type.bg-danger'
		assert_no_selector('#type.bg-success')
		assert_no_selector('#type.bg-warning')

		# click on income
		find('#transactionform #type-income').click

		# verify the color is green
		assert_selector '#type.bg-success'
		assert_no_selector('#type.bg-danger')
		assert_no_selector('#type.bg-warning')

		# click on transfer
		find('#transactionform #type-transfer').click

		# verify the color is orange
		assert_selector '#type.bg-warning'
		assert_no_selector('#type.bg-success')
		assert_no_selector('#type.bg-danger')

		# click on expense
		find('#transactionform #type-expense').click

		# verify the color is red again
		assert_selector '#type.bg-danger'
		assert_no_selector('#type.bg-success')
		assert_no_selector('#type.bg-warning')

	end

	test 'transfer account fields' do

		start

		# verify that the transfer transaction fields are hidden
		assert_selector '#transactionform #transfer-account', visible: :hidden
		# verify that the non-transfer fields are visible
		assert_selector '#transactionform #single-account', visible: :visible
		assert_selector '#transactionform #categories', visible: :visible

		# change type to Transfer
		find('#transactionform #type-transfer').click

		# verify the transfer fields are visible
		assert_selector '#transactionform #transfer-account', visible: :visible
		# verify that the non-transfer fields are hidden
		assert_selector '#transactionform #single-account', visible: :hidden
		assert_selector '#transactionform #categories', visible: :hidden

		# change type to Income
		find('#transactionform #type-income').click

		# verify the original conditions
		assert_selector '#transactionform #transfer-account', visible: :hidden
		assert_selector '#transactionform #single-account', visible: :visible
		assert_selector '#transactionform #categories', visible: :visible

	end

	test 'automatic account selection' do

		start

		# verify that 'current account' is currently selected
		assert find('#transactionform #transaction_account').value == 'Current Account'

		# close the form and go to another account
		click_on I18n.t('buttons.close.text')
		find('#account_Ac0zFCDl8ApZ').click

		# open the transaction form and veryfy that 'current account' is selected
		click_on I18n.t('buttons.new_transaction.text')
		assert find('#transactionform #transaction_account').value == 'Current Account'

		# close the form and go to another account
		click_on I18n.t('buttons.close.text')
		find('#account_sVRZ_GLdEeoA').click

		# open the menu and verify that 'savings account' is selected
		click_on I18n.t('buttons.new_transaction.text')
		assert find('#transactionform #transaction_account').value == 'Savings Account'

	end

	test 'automatic currency selection' do

		start

		# verify that EUR is currently selected
		assert find('#transactionform #transaction_currency').value == 'EUR'

		# select the JPY account
		select 'JPY Account', from: 'Account'

		# verify the currency selection changed to JPY
		assert find('#transactionform #transaction_currency').value == 'JPY'

		# select CAD currency
		select 'CAD', from: 'Currency'

		# change the account back to Current Account
		select 'Current Account', from: 'Account'

		# verify the currency did not change
		assert find('#transactionform #transaction_currency').value == 'CAD'

	end

	test 'transfer account currency fields' do

		start

		# verify the transfer currency conversion is hidden
		assert_selector '#transactionform #transfer-currencies', visible: :hidden

		# change type to transfer
		find('#transactionform #type-transfer').click

		# verify the transfer currency conversion is still hidden
		assert_selector '#transactionform #transfer-currencies', visible: :hidden

		# change the to_account to JPY Account
		select 'JPY Account', from: 'To account'

		# verify the currency conversion fields are visible
		assert_selector '#transactionform #transfer-currencies', visible: :visible

		# change the to_account back to Current Account
		select 'Current Account', from: 'To account'

		# verify the transfer currency conversion is hidden again
		assert_selector '#transactionform #transfer-currencies', visible: :hidden

		# set the from_account to JPY Account
		select 'JPY Account', from: 'From account'

		# verify the conversion fields are visible again
		assert_selector '#transactionform #transfer-currencies', visible: :visible

		# change the type to Income
		find('#transactionform #type-income').click

		# verify the conversion field is hidden
		assert_selector '#transactionform #transfer-currencies', visible: :hidden

	end
=end
	
	test 'select category' do

		start

		find('#transactionform #categories-dropdown').click

		take_screenshot

	end

	def start
		login_user(users(:transactions), 'SomePassword123^!')

		# click on new transaction
		click_on I18n.t('buttons.new_transaction.text')
	end

end