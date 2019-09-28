require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase

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
			page.driver.browser.navigate.refresh
			find('#new-account-button').click
			fill_in 'account[name]', with: "Account #{n}"
			click_on I18n.t('buttons.create_account.text')
		end

		assert_selector '#flash_alert', text: I18n.t('account.failure.upgrade_for_spending')

		find('#accountform button.close').click
		(max_spending..max).each do |n|
			page.driver.browser.navigate.refresh
			find('#new-account-button').click
			fill_in 'account[name]', with: "Account #{n}"
			find('#accountform #account_account_type').find(:option, I18n.t('account.types.saving')).select_option

			click_on I18n.t('buttons.create_account.text')
		end

		assert_selector '#flash_alert', text: I18n.t('account.failure.upgrade_for_accounts')

	end

	test 'Edit account' do

		login_as_blank

		# create an account
		find('#new-account-button').click
		fill_in 'account[name]', with: 'Edit'
		click_on I18n.t('buttons.create_account.text')

		page.driver.browser.navigate.refresh

		# navigate to new account
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

		login_as_blank

		# create an account
		find('#new-account-button').click
		fill_in 'account[name]', with: 'TestAccount'
		click_on I18n.t('buttons.create_account.text')

		page.driver.browser.navigate.refresh

		# edit the account and change the name to 'new'
		visit '/accounts/TestAccount/settings'
		fill_in 'account[name]', with: 'new'
		click_on I18n.t('buttons.edit_account_save.text')

		# verify the name was saved as 'New'
		assert_selector '#accounts_list', text: 'New'

	end

	test 'Quick edit account balance' do

		login_as_blank

		find('#new-account-button').click
		fill_in 'account[name]', with: 'Balance'
		click_on I18n.t('buttons.create_account.text')

		page.driver.browser.navigate.refresh

		visit '/accounts/Balance'

		# verify the balance input field is hidden
		assert_selector 'input#account_balance', visible: :hidden
		# verify the balance span is visible
		assert_selector '#account-title-balance', visible: :visible

		# click on the balance
		find('#account-title-balance').click

		# verify the balance input is visible
		assert_selector 'input#account_balance', visible: :visible
		# verify the balance span is hidden
		assert_selector '#account-title-balance', visible: :hidden

		# fill in a new balance
		fill_in 'account[balance]', with: '1212.01'
		find('input#account_balance').native.send_keys(:return)

		sleep 2

		assert_selector '#accounts_list', text: '€1,212.01'
		assert_selector '#account-title-balance', text: '€1,212.01'

		page.driver.browser.navigate.refresh

		assert_selector '#accounts_list', text: '€1,212.01'
		assert_selector '#account-title-balance', text: '€1,212.01'

		# check if a balancer transaction was created
		balancer = Transaction.where(user_id: 3, is_balancer: true).take
		assert_not balancer.nil?, 'No balancer transaction created'
		assert balancer.amount == 121201, format_error('Unexpected balancer amount', 121201, balancer.amount)

		# verify the balancer transaction isn't visible
		visit '/accounts/Balance'
		assert_no_text 'balancer_transaction'

		# verify that a new account history was recorded
		account = Account.where(user_id: 3, name: 'Balance').take
		history = AccountHistory.where(account_id: account.id, balance: 121201).take
		assert_not history.nil?, 'Account history not recorded after changing its balance'

	end

	test 'delete account' do

		login_as_blank

		find('#new-account-button').click
		fill_in 'account[name]', with: 'Destroy'
		click_on I18n.t('buttons.create_account.text')

		page.driver.browser.navigate.refresh

		visit '/accounts/Destroy/settings'

		click_on I18n.t('buttons.delete_account.text')

		# assert the warning text is showing
		assert_selector '#confirmation_modal', text: I18n.t('account.delete_warning')

		# deny the confirmation and check that the account wasn't deleted
		click_on I18n.t('buttons.deny.text')
		page.driver.browser.navigate.refresh
		assert_selector '#accounts_list', text: 'Destroy'

		# delete the account for real
		click_on I18n.t('buttons.delete_account.text')
		click_on I18n.t('buttons.confirm.text')

		visit root_path

		# verify the account was deleted
		assert_no_text 'Destroy'

	end

	test "new account in transaction form" do
    """
    Create a new account
    The new account is inserted using Ajax
    Without refreshing the page, go to 'New Transaction' and check if the newly created account is an option in the account selectors
    """
    account_name = "include this account in transaction form"

    login_as_blank

    # Open the new account menu
    page.find("#new-account-button").click
    # Find and store the submit button
    submit = page.find("#accountform button[type=submit]")
    # Fill in an account name
    fill_in "account[name]", with: account_name
    # Save the account
    click_on "Create Account"
    
    sleep 1
    click_on "New Transaction"
    sleep 1

    # select the new account from the account selector. If it's not available, it will throw an error
    select account_name, from: "Account"

    # select the new account from the account selector. If it's not available, it will throw an error
    page.find("#transactionform #type-transfer").click
    select account_name, from: "From account"
    select account_name, from: "To account"

  end

  test 'Transaction visible test' do

    current_user = users(:bas)

    login_user(current_user, 'SomePassword123^!')

    ids = ["jvkHRHdOLFH-", "3wPNUsSvn8YP", "9nmxbbf1tedH", "o8xIIKx1MCzz", "SNilsHJqNRoi"]

    for i in 0..4
        page.find("#account_#{ids[i]}").click

        for x in 1..i
            assert_selector 'li', text: "transaction " + x.to_s + "\n€#{x}.00"
        end
    end

  end

  test 'Endless page test' do
    current_user = users(:endless_page)

    login_user(current_user, 'SomePassword123^!')

    page.find("#account_KpI4Cq6dLiYo").click

    sleep 1
    assert_selector 'li', text: "transaction 1\n€1.00"
    assert_select 'li', {count: 0, text: "transaction 100"}

    5.times do
        page.execute_script "window.scrollBy(0,10000)"
        sleep 1
    end

    assert_selector 'li', text: "transaction 100"
  end

end