require "application_system_test_case"

class SchedulesTest < ApplicationSystemTestCase
  test "visit the schedules page" do
    """
    log in as blank user and navigate to the schedules page
    Expected result:
      - See the schedules page
      - A list with active schedules saying there are no active schedules
      - A list with inactive schedules saying there are no inactive schedules
      - A button to create a new schedule
    """

    login_as_blank
    page.find(".navbar-gear").click
    click_on "Schedules"

    assert_selector 'h2', text: 'Schedules'
    assert_selector 'h3', text: 'Active Schedules'
    assert_selector 'h3', text: 'Inactive Schedules'

    assert_selector '#active-schedules ul', text: I18n.t('schedules.no_active_schedules')
    assert_selector '#inactive-schedules ul', text: I18n.t('schedules.no_inactive_schedules')

    assert_selector 'button#new-schedule-button', text: "New Schedule"
  end

  test "open and close schedule form" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    # check if the menu is visible
    assert_selector '#scheduleform', visible: :visible
    assert_selector '#scheduleform h5', text: 'New Schedule'

    # close the menu
    page.find("#scheduleform button.close").click

    # check if menu is hidden
    assert_selector '#transactionform', visible: :hidden
  end

  test "default fields" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    assert_selector ("#scheduleform #type-simple"), text: "Simple"
    assert_selector ("#scheduleform #type-advanced"), text: "Advanced"

    assert_selector '#scheduleform input#schedule_name', visible: :visible
    assert_selector '#scheduleform select#schedule_period', visible: :visible
    assert_selector '#scheduleform input#schedule_period_numeric', visible: :visible
  end

  test "submit button disabled on empty name" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    # Find and store the submit button
    submit = page.find("#scheduleform input[type=submit]")
    # Check if button is disabled correctly
    assert submit[:disabled] == "", format_error("Save schedule button not disabled when name is blank", "disabled = true", "disabled = " + submit[:disabled].to_s)

    # Fill in a name
    #fill_in "#schedule_name", with: "t"
    #assert !submit[:disabled], format_error("Save schedule button disabled when name is not blank", "disabled = false", "disabled = " + submit[:disabled].to_s)
  end
end
