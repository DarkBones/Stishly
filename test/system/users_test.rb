require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
	test 'visit the index' do
		"""
		Go the the root path
		Expected result:
		- See welcome screen
		- See link to sign up
		- See link to sign in
		"""

		visit root_path

		assert_selector 'h1', text: "Sign Up"

		assert_selector '.navbar-nav', text: I18n.t('views.devise.shared.buttons.sign_up.text')
		assert_selector '.navbar-nav', text: I18n.t('views.devise.shared.buttons.sign_in.text')
	end

	test 'create user account' do
		"""
		Create a user account
		Expected result:
		- Not able to create the account when not filling in the form completely
		- Abe to create the account after filling in the form completely
		"""

		# form fields to be filled in
		form_fields = [
      {
        type: 'text',
        name: I18n.t('helpers.label.user.first_name'),
        value: 'System'
      },
      {
        type: 'text',
        name: I18n.t('helpers.label.user.last_name'),
        value: 'Test'
      },
      {
        type: 'text',
        name: I18n.t('helpers.label.user.email'),
        value: 'system_test@example.com'
      },
      {
        type: 'text',
        name: I18n.t('helpers.label.user.password'),
        value: 'Fallout76IsAGem^!'
      },
      {
        type: 'text',
        name: I18n.t('helpers.label.user.password_confirmation'),
        value: 'Fallout76IsAGem^!'
      }
    ]

    # Fill in the registration form, ommitting one field each time. On the final run, it will fill in all the details
    for i in 0..form_fields.length do
      visit root_path

      all('a', :text => I18n.t('views.devise.shared.buttons.sign_up.text'))[0].click

      form_fields.each_with_index do |f, idx|
        if idx != i
          if f[:type] == 'text'
            fill_in f[:name], with: f[:value]
          else
            select f[:value], from: f[:name]
          end
        end
      end

      find('button[type="submit"]').click

      if i < form_fields.length
        assert_selector 'h2', text: I18n.t('views.shared.errors.form')
      else
        assert_selector '#flash_notice', text: I18n.t('devise.registrations.signed_up')
      end
    end
	end

	test 'log in as blank' do
		"""
		Login as a user, then log out again
		Expected result:
		- See notification that sign in was successful
    - See notification that the logout was successful
    - See welcome screen
    - See sign up / sign in links
		"""

		login_user(users(:bas), 'SomePassword123^!')

		assert_selector '#flash_notice', text: I18n.t('devise.sessions.signed_in')

		assert_selector '.navbar-nav', text: I18n.t('views.devise.shared.buttons.sign_up.text') == false
		assert_selector '.navbar-nav', text: I18n.t('views.devise.shared.buttons.sign_in.text') == false

		page.find('.navbar-gear').click
		click_on 'Sign Out'

		assert_selector '#flash_notice', text: I18n.t('devise.sessions.signed_out')

		assert_selector '.navbar-nav', text: I18n.t('views.devise.shared.buttons.sign_up.text')
		assert_selector '.navbar-nav', text: I18n.t('views.devise.shared.buttons.sign_in.text')
	end

	test 'destroy account' do
		"""
		Login as a user, and delete the account
    Expected result:
    - See notification that sign in was successful
    - See notification that account was cancelled
    - See welcome screen
    - See sign up / sign in links
    - Get an error when trying to log in again
    """

    login_user(users(:destroy), 'SomePassword123^!')
    page.find('.navbar-gear').click

    click_on "Edit Account"

    click_on "Delete My Account"

    page.driver.browser.switch_to.alert.accept

    assert_selector '#flash_notice', text: I18n.t('devise.registrations.destroyed')

    login_user(users(:destroy), 'SomePassword123^!')
    assert_selector '#flash_alert', text: I18n.t('devise.failure.not_found_in_database')
	end

end