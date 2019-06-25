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
    assert_selector '#scheduleform', visible: :hidden
  end

  test "default fields" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    assert_selector '#scheduleform #type-simple.active', text: 'Simple'
    assert_selector '#scheduleform #schedule_name'

    schedule_period = page.find('#scheduleform #schedule_schedule').value
    assert schedule_period == 'monthly', format_error('unexpected schedule selection', 'monthly', schedule_period)

    schedule_start_date = page.find('#scheduleform #schedule_start_date').value
    assert schedule_start_date == Time.now.strftime("%d-%b-%Y"), format_error('unexpected start date', Time.now.strftime("%d-%b-%Y"),schedule_start_date)

    run_every = page.find('#scheduleform #schedule_run_every').value
    assert run_every == '1', format_error('unexpected schedule period num', '1', run_every)

    period_indicator = page.find('#scheduleform #period').text
    assert period_indicator == 'Months', format_error('unexpected period indicator', 'Months', period_indicator)

    assert_selector '.schedule-advanced', visible: :hidden
  end

  test "change simple period" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"
    
    select 'Daily', from: "schedule[schedule]"
    period_indicator = page.find('#scheduleform #period').text
    assert period_indicator == 'Days', format_error('unexpected period indicator', 'Days', period_indicator)

    select 'Weekly', from: "schedule[schedule]"
    period_indicator = page.find('#scheduleform #period').text
    assert period_indicator == 'Weeks', format_error('unexpected period indicator', 'Weeks', period_indicator)

    select 'Monthly', from: "schedule[schedule]"
    period_indicator = page.find('#scheduleform #period').text
    assert period_indicator == 'Months', format_error('unexpected period indicator', 'Months', period_indicator)

    select 'Annually', from: "schedule[schedule]"
    period_indicator = page.find('#scheduleform #period').text
    assert period_indicator == 'Years', format_error('unexpected period indicator', 'Years', period_indicator)

  end

  test "change schedule period number" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    fill_in 'schedule[run_every]', with: '60'
    run_every = page.find('#scheduleform #schedule_run_every').value
    assert run_every == '60', format_error('unexpected schedule period num', '60', run_every)
  end

  test "advanced options" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    page.find('#scheduleform #type-advanced').click

    select 'Daily', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :hidden
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    select 'Weekly', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :visible
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :hidden
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    select 'Monthly', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :visible
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :visible
    assert_selector '#scheduleform #schedule_end_date', visible: :hidden
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    select 'Annually', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :hidden
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden
  end

  test "very advanced options" do
    login_as_blank
    visit "/schedules"
    click_on "New Schedule"

    page.find('#scheduleform #type-advanced').click
    click_on 'show advanced options'

    select 'Daily', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :visible
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    select 'Weekly', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :visible
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :visible
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    select 'Monthly', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :visible
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :visible
    assert_selector '#scheduleform #schedule_end_date', visible: :visible
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :visible
    assert_selector '#scheduleform #weekday-exclude', visible: :visible
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    select 'Annually', from: "schedule[schedule]"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :visible
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden

    click_on "hide advanced options"
    assert_selector '#scheduleform #button-group-weekdays', visible: :hidden
    assert_selector '#scheduleform #schedule_days', visible: :hidden
    assert_selector '#scheduleform #schedule_days2', visible: :hidden
    assert_selector '#scheduleform #daypicker', visible: :hidden
    assert_selector '#scheduleform #schedule_end_date', visible: :hidden
    assert_selector '#scheduleform #schedule_exclusion_met1', visible: :hidden
    assert_selector '#scheduleform #weekday-exclude', visible: :hidden
    assert_selector '#scheduleform #daypicker-exclude', visible: :hidden
  end

  test "transaction category" do
     login_user(users(:schedules), 'SomePassword123^!')

     visit "/schedules"
     page.find("#schedule-transactions-button_1").click
     click_on "New Transaction"
     take_screenshot
  end
  
end