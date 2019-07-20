require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase

  test "login" do
  	user = users(:new)
  	user = users(:new)
    password = "SomePassword123^!"

    login_user(user, password)
  end

end