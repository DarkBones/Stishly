require "application_system_test_case"

class TransactionMenuTest < ApplicationSystemTestCase

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

	test "default transaction menu fields" do
    """
    Log in and click on 'new transaction'
    The following fields are visible from the start:
    - #single-account
    - #categories
    - #amount
    The following fields are hidden from the start:
    - #transfer-account
    - #currency-rate
    - #currency-result
    - #transactions
    """
    # login as transactions user
    login_user(users(:transactions), 'SomePassword123^!')

    # open the transaction menu
    click_on "New Transaction"

    # assert the visible fields
    assert_selector '#single-account', visible: :visible
    assert_selector '#categories', visible: :visible
    assert_selector '#amount', visible: :visible

    # assert the hidden fields
    assert_selector '#transfer-account', visible: :hidden
    assert_selector '#currency-rate', visible: :hidden
    assert_selector '#currency-result', visible: :hidden
    assert_selector '#transactions', visible: :hidden
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
	
	test 'select category' do

		start

		category = Category.where(user_id: 8, name: "Cinema").take

		# open the category dropdown
		find('#transactionform #categories-dropdown').click

		# click on Cinema
		find(".category_#{category.hash_id}").click

		# verify the button has text "Cinema"
		assert_selector '#categories-dropdown', text: 'Cinema'
		# verify the button has the film symbol
		assert_selector '#categories-dropdown .fa-film'
		# verify the hidden field contains the hash_id of the cinema category
		assert find('#edit_transaction__category_id_', visible: :all).value == category.hash_id

	end

	test 'search categories' do

		start

		category = Category.where(user_id: 8, name: "Cinema").take
		all_catagories = Category.where(user_id: 8)

		# open the category dropdown
		find('#transactionform #categories-dropdown').click

		# verify all categories are visible
		all_catagories.each do |c|
			assert_selector '#transactionform #categoriesDropdownOptions_', text: c.name
		end

		# search for "cin"
		find('#transactionform #search-categories_').set('cine')

		# verify all categories except "Cinema" and its parents are hidden
		all_catagories.each do |c|
			if !["Entertainment", "Date", "Cinema"].include? c.name
				assert_no_selector "#transactionform #categoriesDropdownOptions_ .category_#{c.hash_id}"
			elsif ["Entertainment", "Date"].include? c.name
				# verify the parent categories have class "grey-out"
				assert_selector "#transactionform #categoriesDropdownOptions_ .category_#{c.hash_id}.grey-out"
			else
				# verify the Cinema category does not have class grey-out
				assert_no_selector "#transactionform #categoriesDropdownOptions_ .category_#{c.hash_id}.grey-out"
			end
		end

	end

	test 'multiple transactions field' do

		start

		# verify the multiple transactions field is hidden
		assert_selector '#transactionform #transaction_transactions', visible: :hidden

		# verify the single transaction field is visible
		assert_selector '#transactionform #transaction_amount', visible: :visible

		# click on "Multiple"
		find('#transactionform #multiple-multiple').click

		# verify the multiple transactions field is visible
		assert_selector '#transactionform #transaction_transactions', visible: :visible

		# verify the single transaction field is hidden
		assert_selector '#transactionform #transaction_amount', visible: :hidden

		# click on "Single"
		find('#transactionform #multiple-single').click

		# verify the multiple transactions field is hidden
		assert_selector '#transactionform #transaction_transactions', visible: :hidden

		# verify the single transaction field is visible
		assert_selector '#transactionform #transaction_amount', visible: :visible

	end

	test 'multiple transactions total' do

		start

		# click on "Multiple"
		find('#transactionform #multiple-multiple').click

		# fill in transactions
		find('#transactionform #transaction_transactions').set("one 1.01\ntwo 2\nthree 3.5\nfour 4")

		# verify the transaction total updated
		assert_selector '#transactionform #transaction_total_indicator', text: '€10.51'

		# select CAD as currency
		select 'CAD', from: 'Currency'

		# verify the transaction total now displays in CAD
		assert_selector '#transactionform #transaction_total_indicator', text: '$10.51'

		# select JPY as currency
		select 'JPY', from: 'Currency'

		# verify the total has changed accordingly
		assert_selector '#transactionform #transaction_total_indicator', text: '¥11'

	end

	test 'currency conversion fields' do

		start

		# verify the conversion fields are hidden
		assert_selector '#transactionform #currency-rate', visible: :hidden

		# select JPY as currency
		select 'JPY', from: 'Currency'

		# verify the conversion fields are visible
		assert_selector '#transactionform #currency-rate', visible: :visible

		# verify the label is set to "Amount in EUR"
		assert_selector '#transactionform #currency-result', text: 'Amount in EUR'

		# select EUR as currency
		select 'EUR', from: 'Currency'

		# verify the conversion fields are hidden again
		assert_selector '#transactionform #currency-rate', visible: :hidden

	end

	test 'currency conversion rate' do

		start

		# select JPY as currency
		select 'JPY', from: 'Currency'

		# verify the conversion rate is set correctly
		assert find('#transactionform #transaction_rate').value == "0.008", format_error('Unexpected conversion rate', '0.008', find('#transactionform #transaction_rate').value)

		# verify the amount in EUR is 0
		assert find('#transactionform #transaction_account_currency').value == '0', format_error('Unexpected account currency amount', '0', find('#transactionform #transaction_account_currency').value)

		# fill in an amount
		find('#transactionform #transaction_amount').set('1000')

		sleep 1

		# verify the amount in EUR is 8
		assert find('#transactionform #transaction_account_currency').value.to_f >= 0.8, format_error('Unexpected account currency amount', '8.00', find('#transactionform #transaction_account_currency').value)

		# click on "Multiple"
		find('#transactionform #multiple-multiple').click

		sleep 1

		# verify the amount in EUR is 0
		assert find('#transactionform #transaction_account_currency').value == '0.00', format_error('Unexpected account currency amount', '0.00', find('#transactionform #transaction_account_currency').value)

		# fill in transactions
		find('#transactionform #transaction_transactions').set("one 10\ntwo 20\nthree 30\nfour 40")

		sleep 1

		# verify the amount in EUR is 0.80
		assert find('#transactionform #transaction_account_currency').value == '0.80', format_error('Unexpected account currency amount', '0.80', find('#transactionform #transaction_account_currency').value)

		# click on "Single"
		find('#transactionform #multiple-single').click

		sleep 1

		# verify the amount in EUR is 8
		assert find('#transactionform #transaction_account_currency').value == '8.00', format_error('Unexpected account currency amount', '8.00', find('#transactionform #transaction_account_currency').value)

		# click on "Multiple"
		find('#transactionform #multiple-multiple').click

		sleep 1

		# verify the amount in EUR is 0.80
		assert find('#transactionform #transaction_account_currency').value == '0.80', format_error('Unexpected account currency amount', '0.80', find('#transactionform #transaction_account_currency').value)

	end

	test 'currency conversion result' do

		start

		# select JPY as currency
		select 'JPY', from: 'Currency'

		# set amount to 1000
		find('#transactionform #transaction_amount').set('1000')

		# change the result to 500
		find('#transactionform #transaction_account_currency').set('500')

		# verify the conversion rate is 0.5
		assert find('#transactionform #transaction_rate').value == '0.5', format_error('Unexpected conversion rate', '0.5', find('#transactionform #transaction_rate').value)

		# change the conversion rate to 2.1
		find('#transactionform #transaction_rate').set('2.1')

		sleep 1

		# verify the result is 2100
		assert find('#transactionform #transaction_account_currency').value.to_f >= 2000, format_error('Unexpected conversion result', '2100.00', find('#transactionform #transaction_account_currency').value )

	end

	def start
		login_user(users(:transactions), 'SomePassword123^!')

		# click on new transaction
		click_on I18n.t('buttons.new_transaction.text')
	end

end