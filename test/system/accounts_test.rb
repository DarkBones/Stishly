require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase

=begin
	test 'Open and close the menu' do

		login_as_blank

		# there are no existing accounts, so the create account instruction should be visible
		assert_selector '#accounts_list', text: I18n.t('account.instructions.create')

		# click on the instruction and verify the new account window is visible
		find('#create-account-instruction').click
		assert_selector '#accountform', visible: :visible

		# click on the close button and verify the account window is hidden
		find('#accountform button.close').click
		assert_selector '#accountform', visible: :hidden

		# click on the plus button and verify the new account window is visible
		find('#new-account-button').click
		assert_selector '#accountform', visible: :visible

	end

	test 'Create simple account' do

		login_as_blank

		# open the account menu
		find('#new-account-button').click

		# fill in the details
		fill_in 'account[name]', with: 'test account one'
		fill_in 'account[balance]', with: '50000'
		
		# save the account
		click_on I18n.t('buttons.create_account.text')

		# verify the account is listed
		assert_selector '#accounts_list', text: 'test account one'
		assert_selector '#accounts_list', text: '€50,000.00'

		# verify the account creation instruction was removed
		assert_no_selector('#create-account-instruction')

	end

	test 'Duplicate account names' do

		login_as_blank

		# create an account
		find('#new-account-button').click
		fill_in 'account[name]', with: 'test account one'
		fill_in 'account[balance]', with: '50000'
		click_on I18n.t('buttons.create_account.text')

		# create an account with the same name
		find('#new-account-button').click
		fill_in 'account[name]', with: 'test account one'
		fill_in 'account[balance]', with: '10'
		click_on I18n.t('buttons.create_account.text')

		# verify that the notification saying an account with the same name already exists comes up
		assert_selector '#flash_alert', text: I18n.t('account.failure.already_exists')

	end

	test 'No name' do

		login_as_blank

		find('#new-account-button').click
		click_on I18n.t('buttons.create_account.text')

		# verify that the notification saying a name is required comes up
		assert_selector '#flash_alert', text: I18n.t('account.failure.no_name')

	end

	test 'Reset account fields' do

		login_as_blank

		# fill in the details
		find('#new-account-button').click
		fill_in 'account[name]', with: 'test account name'
		fill_in 'account[balance]', with: '50000'
		fill_in 'account[description]', with: 'test account description'
		find('#accountform #account_currency').find(:option, 'JPY').select_option
		find('#accountform #account_account_type').find(:option, I18n.t('account.types.saving')).select_option

		# close the menu
		find('#accountform button.close').click

		# open the menu again and verify the fields were reset
		find('#new-account-button').click

		assert find('#accountform #account_name').value == '', 'Account name did not reset'
		assert find('#accountform #account_balance').value == '0', 'Account balance did not reset'
		assert find('#accountform #account_description').value == '', 'Account description did not reset'
		assert find('#accountform #account_currency').value == 'EUR', 'Account currency did not reset'
		assert find('#accountform #account_account_type').value == 'spend', 'Account type did not reset'

	end

	test 'Special characters in account name' do

		login_as_blank

		find('#new-account-button').click

		# special characters
		chars = ['-', '.', '~', ':', '/', '?', '#', '[', ']', '@', '!', '$', '&', '\'', '(', ')', '*', '+', ',', ';', '=', '{', '}', '\\']
		chars.each do |c|
			fill_in 'account[name]', with: "test #{c}"
			click_on I18n.t('buttons.create_account.text')

			assert_selector '#flash_alert', text: I18n.t('account.failure.special_characters')
		end

	end

	test 'Balance formats' do

		login_as_blank

		# create an account with 0.01 EUR balance
		find('#new-account-button').click
		fill_in 'account[name]', with: 'test EUR'
		fill_in 'account[balance]', with: '0.01'
		click_on I18n.t('buttons.create_account.text')
		assert_selector '#accounts_list', text: '€0.01'

		# create an account with 1.51 JPY
		find('#new-account-button').click
		fill_in 'account[name]', with: 'test JPY'
		find('#accountform #account_currency').find(:option, 'JPY').select_option
		fill_in 'account[balance]', with: '1.51'
		click_on I18n.t('buttons.create_account.text')
		assert_selector '#accounts_list', text: '¥2'

	end

	test 'Name as "new"' do

		login_as_blank

		# create an account with name = 'new'. It should convert to 'New'
		find('#new-account-button').click
		fill_in 'account[name]', with: 'new'
		click_on I18n.t('buttons.create_account.text')

		assert_selector '#accounts_list', text: 'New'

	end
	test 'Create too many accounts' do

		login_as_blank_free

		free_tier = SubscriptionTier.where(name: 'Free').take
		max = free_tier.max_accounts
		max_spending = free_tier.max_spending_accounts

		(0..max_spending).each do |n|
			find('#new-account-button').click
			fill_in 'account[name]', with: "Account #{n}"
			click_on I18n.t('buttons.create_account.text')
		end

		assert_selector '#flash_alert', text: I18n.t('account.failure.upgrade_for_spending')

		find('#accountform button.close').click
		(max_spending..max).each do |n|
			find('#new-account-button').click
			fill_in 'account[name]', with: "Account #{n}"
			find('#accountform #account_account_type').find(:option, I18n.t('account.types.saving')).select_option

			click_on I18n.t('buttons.create_account.text')
		end

		assert_selector '#flash_alert', text: I18n.t('account.failure.upgrade_for_accounts')

	end

=end
	test 'Edit account' do

		login_as_blank

		# create an account
		find('#new-account-button').click
		fill_in 'account[name]', with: 'Edit'
		click_on I18n.t('buttons.create_account.text')

		# navigate to new account
		find('#accounts_list', text: 'Edit').click
		visit '/accounts/Edit/settings'
		
		fill_in 'account[name]', with: 'EditNewName'
		fill_in 'account[balance]', with: '500.51'
		fill_in 'account[description]', with: 'test description'
		find('#account_account_type').find(:option, I18n.t('account.types.saving')).select_option

		click_on I18n.t('buttons.edit_account_save.text')

		visit '/accounts/EditNewName/settings'
		assert find('#account_name').value == 'EditNewName', 'Account name not saved'
		assert find('#account_balance').value == '500.51', 'Account balance not saved'
		assert find('#account_description').value == 'test description', 'Account description not saved'
		assert find('#account_account_type').value == 'save', 'Account type not saved'

	end

	test 'Edit account, change name to "new"' do

	end

end