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

    assert_selector 'h1', text: 'Welcome'
    assert_selector '.navbar-nav', text: 'Sign up'
    assert_selector '.navbar-nav', text: 'Sign in'

    take_screenshot
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
        assert_selector 'h2', text: 'Please fix the below errors'
      else
        assert_selector '#flash_notice', text: 'signed up successfully'
      end

      page.save_screenshot 'tmp/screenshots/test_creating_user_account_' + i.to_s + '.png'
    end
  end

  test 'log in blank user' do
    """
    Login as a newly created user
    Expected result:
    - See notification that sign in was successfull
    - See empty list of accounts
    """

    user = users(:new)
    password = "SomePassword123^!"

    login_user(user, password)

    take_screenshot

    assert_selector '#flash_notice', text: 'Signed in successfully'
    assert_selector '#left-menu', text: 'Create an account by clicking the + button'
  end
end
