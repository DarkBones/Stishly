require "application_system_test_case"

class SchedulesTableTest < ApplicationSystemTestCase
  test "Navigate to schedules index" do
    schedule_login

    assert_selector "h3", text: "Active Schedules"
    assert_selector "h3", text: "Inactive Schedules"
  end

  test "Schedules visible" do
    schedule_login

    assert_selector 'table#schedules_active tr td', text: 'Payday'
    assert_selector 'table#schedules_active tr td', text: 'Bonus day'
    assert_selector 'table#schedules_active tr td', text: 'Payday CVG'
    assert_selector 'table#schedules_active tr td', text: 'Bonus day CVG'

    assert_selector 'table#schedules_active tr td', text: '28/03/2018'
    assert_selector 'table#schedules_active tr td', text: '28/04/2018'
    assert_selector 'table#schedules_active tr td', text: '29/03/2018'
    assert_selector 'table#schedules_active tr td', text: '31/05/2018'

    #assert_selector 'table#schedules_inactive tr td', text: 'Inactive schedule'
    #assert_selector 'table#schedules_inactive tr td', text: '31/05/2018'
  end

  def schedule_login
    user = users(:schedules)
    password = "SomePassword123^!"
    login_user(user, password)
    click_on "Schedules"
  end

end