require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Devise::Controllers::Helpers

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def login_user(user, password)
    visit root_path

    all('a', :text => 'Sign in')[0].click

    fill_in "Email", with: user.unconfirmed_email
    fill_in "Password", with: password

    #page.execute_script("$('input[name=\"commit\"]').click()")
    #page.execute_script("$('input[type=\"submit\"]').click()")
    find('button[type="submit"]').click
  end

  def login_as_blank
    user = users(:new)
    password = "SomePassword123^!"

    login_user(user, password)
  end

  def login_as_blank_free
    user = users(:new_free)
    password = "SomePassword123^!"

    login_user(user, password)
  end

  def logout
    sleep 2
    page.find(".navbar-gear").click
    click_on "Sign out"
  end
end
