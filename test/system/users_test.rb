require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'visiting the index' do
    visit root_path

    assert_selector 'h1', text: 'Welcome'
    assert_selector '.navbar-nav', text: 'Sign up'
    assert_selector '.navbar-nav', text: 'Sign in'
  end

  test 'creating user account' do
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
        value: 'somepassword123'
      },
      {
        type: 'text',
        name: 'Password confirmation',
        value: 'somepassword123'
      }
    ]

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

    #fill_in 'First name', with: 'System'
    #fill_in 'Last name', with: 'Test'
    #fill_in 'Email', with: 'system_test@example.com'
    #select 'Ireland', from: 'user_country_code'
    #fill_in 'Password', with: 'somepassword123'
    #fill_in 'Password confirmation', with: 'somepassword123'

    #find('input[name="commit"]').click

    #take_screenshot
  end
end
