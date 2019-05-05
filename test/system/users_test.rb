require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  

  test 'visiting the index' do
    """
    Goes to the root path without logging in.
    Expected result: 
    - See welcome screen
    - See link to sign up
    - See link to sign in
    """

    visit root_path

    assert_selector 'h1', text: I18n.t('homepage.welcome_h1')

    assert_selector '.navbar-nav', text: 'Sign up'
    assert_selector '.navbar-nav', text: 'Sign in'

  end

  test 'creating user account' do
    """
    Creates a user account.
    Expected result:
    - Not able to create the account when not filling in the form completely
    - Able to create the account after filling in the form completely
    """

    # Form to be filled in
    form_fields = [
      {
        type: 'text',
        name: 'First name',
        value: 'System'
      },
      {
        type: 'text',
        name: 'Last name',
        value: 'Test'
      },
      {
        type: 'text',
        name: 'Email',
        value: 'system_test@example.com'
      },
      {
        type: 'select',
        name: 'user_country_code',
        value: 'Ireland'
      },
      {
        type: 'text',
        name: 'Password',
        value: 'Somepassword123^'
      },
      {
        type: 'text',
        name: 'Password confirmation',
        value: 'Somepassword123^'
      }
    ]

    # Fill in the registration form, ommitting one field each time. On the final run, it will fill in all the details
    for i in 0..form_fields.length do
      visit root_path

      all('a', :text => 'Sign up')[0].click

      form_fields.each_with_index do |f, idx|
        if idx != i
          if f[:type] == 'text'
            fill_in f[:name], with: f[:value]
          else
            select f[:value], from: f[:name]
          end
        end
      end

      find('input[name="commit"]').click

      if i < form_fields.length
        assert_selector 'h2', text: I18n.t('errors.form')
      else
        assert_selector '#flash_notice', text: I18n.t('devise.registrations.signed_up')
      end

      #page.save_screenshot 'tmp/screenshots/test_creating_user_account_' + i.to_s + '.png'
    end
  end

  test 'log in blank user' do
    """
    Login as a newly created user
    Expected result:
    - See notification that sign in was successful
    - See empty list of accounts
    """

    user = users(:new)
    password = "SomePassword123^!"

    login_user(user, password)

    assert_selector '#flash_notice', text: I18n.t('devise.sessions.signed_in')
    assert_selector '#sidebar', text: I18n.t('account.instructions.create')
  end

  test 'log out' do
    """
    Login as a user, and then log out again
    Expected result:
    - See notification that sign in was successful
    - See notification that the logout was successful
    - See welcome screen
    - See sign up / sign in links
    """

    user = users(:bas)
    password = "SomePassword123^!"

    login_user(user, password)

    assert_selector '#flash_notice', text: I18n.t('devise.sessions.signed_in')

    page.find(".navbar-gear").click
    click_on "Sign out"

    assert_selector '#flash_notice', text: I18n.t('devise.sessions.signed_out')
    assert_selector 'h1', text: I18n.t('homepage.welcome_h1')

    assert_selector '.navbar-nav', text: 'Sign up'
    assert_selector '.navbar-nav', text: 'Sign in'
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

    user = users(:destroy)
    password = "SomePassword123^!"

    login_user(user, password)

    assert_selector '#flash_notice', text: I18n.t('devise.sessions.signed_in')

    page.find(".navbar-gear").click

    click_on "Edit account"

    click_on "Delete my account"

    page.driver.browser.switch_to.alert.accept

    assert_selector '#flash_notice', text: I18n.t('devise.registrations.destroyed')
    assert_selector 'h1', text: I18n.t('homepage.welcome_h1')

    login_user(user, password)
    assert_selector '#flash_alert', text: I18n.t('devise.failure.not_found_in_database')
  end

  test "Automatic currency selection" do
    """
    Click 'sign up'
    Select Ireland as country
    Expected result: Currency is set to 'EUR'
    Select Canada as country
    Expected result: Currency is set to 'CAD'
    Select Japan as country
    Expected result: Currency is set to 'JPY'
    Select USD as currency
    Select Netherlands as country
    Expected result: Currency is set to 'USD'
    """

    visit root_path

    all('a', :text => 'Sign up')[0].click

    select "Ireland", from: "user_country_code"
    assert_selector "#user_currency", text: "EUR"

    select "Canada", from: "user_country_code"
    assert_selector "#user_currency", text: "CAD"

    select "Japan", from: "user_country_code"
    assert_selector "#user_currency", text: "JPY"

    select "USD", from: "user_currency"
    select "Netherlands", from: "user_country_code"
    assert_selector "#user_currency", text: "USD"
  end

end
