# == Schema Information
#
# Table name: schedules
#
#  id                :bigint(8)        not null, primary key
#  name              :string(255)
#  user_id           :bigint(8)
#  start_date        :date
#  end_date          :date
#  period            :string(255)
#  period_num        :integer
#  days              :integer
#  days_month        :string(255)
#  days_month_day    :string(255)
#  days_exclude      :integer
#  exclusion_met     :string(255)
#  exclusion_met_day :string(255)
#  timezone          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_active         :boolean          default(TRUE)
#

require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test "Create Schedule" do
    current_user = users(:bas)

    params = {
      name: "test schedule",
      start_date: Time.now,
      period: "month",
      period_num: 1,
      days: 0b0 | (1 << 28),
      days_exclude: 0b0 | (1 << 5) | (1 << 6),
      exclusion_met: "previous",
      exclusion_met_day: "fri",
      timezone: "Europe/London"
    }

    schedule = current_user.schedules.build(params)
    assert schedule.save
  end

  test "Schedule without name" do
    current_user = users(:bas)

    params = {
      start_date: Time.now,
      period: "month",
      period_num: 1,
      days: 0b0 | (1 << 28),
      days_exclude: 0b0 | (1 << 5) | (1 << 6),
      exclusion_met: "previous",
      exclusion_met_day: "fri",
      timezone: "Europe/London"
    }

    schedule = current_user.schedules.build(params)
    assert_not schedule.save, "Saved schedule without name"
  end

  test "Schedule without start date" do
    current_user = users(:bas)

    params = {
      name: "test schedule",
      period: "month",
      period_num: 1,
      days: 0b0 | (1 << 28),
      days_exclude: 0b0 | (1 << 5) | (1 << 6),
      exclusion_met: "previous",
      exclusion_met_day: "fri",
      timezone: "Europe/London"
    }

    schedule = current_user.schedules.build(params)
    assert_not schedule.save, "Saved schedule without start date"
  end

  test "Schedule from form" do
    current_user = users(:bas)

    params = {
      type: 'advanced',
      name: 'test schedule',
      start_date: '17-Mar-2019',
      timezone: 'Europe/London',
      schedule: 'monthly',
      run_every: '1',
      days: 'specific',
      days2: 'day',
      dates_picked: ' 28',
      weekday_mon: '0',
      weekday_tue: '0',
      weekday_wed: '0',
      weekday_thu: '0',
      weekday_fri: '0',
      weekday_sat: '0',
      weekday_sun: '0',
      end_date: '02-feb-2020',
      weekday_exclude_mon: '0',
      weekday_exclude_tue: '0',
      weekday_exclude_wed: '0',
      weekday_exclude_thu: '0',
      weekday_exclude_fri: '0',
      weekday_exclude_sat: '1',
      weekday_exclude_sun: '1',
      dates_picked_exclude: '',
      exclusion_met1: 'previous',
      exclusion_met2: 'fri'
    }

    schedule = Schedule.create_from_form({schedule: params}, current_user)
    assert schedule.is_a?(ActiveRecord::Base), format_error("Schedule from form didn't return schedule")
  end

  test "simple monthly schedule" do
    current_user = users(:bas)

    params = {
      type: 'simple',
      name: 'test schedule',
      start_date: '17-Mar-2019',
      timezone: 'Europe/London',
      schedule: 'monthly',
      run_every: '1',
      days: 'specific',
      days2: 'day',
      dates_picked: ' 28',
      weekday_mon: '0',
      weekday_tue: '0',
      weekday_wed: '0',
      weekday_thu: '0',
      weekday_fri: '0',
      weekday_sat: '1',
      weekday_sun: '1',
      end_date: '20-Feb-2020',
      weekday_exclude_mon: '0',
      weekday_exclude_tue: '0',
      weekday_exclude_wed: '0',
      weekday_exclude_thu: '0',
      weekday_exclude_fri: '0',
      weekday_exclude_sat: '1',
      weekday_exclude_sun: '1',
      dates_picked_exclude: '',
      exclusion_met1: 'previous',
      exclusion_met2: 'fri'
    }

    schedule = Schedule.create_from_form({schedule: params}, current_user)
    assert schedule.name == 'test schedule', format_error("Unexpected schedule name", 'test schedule', schedule.name)
    assert schedule.days_month == '', format_error("Unexpected schedule days_month", '', schedule.days_month)
    assert schedule.end_date == nil, format_error("Unexpected schedule end date", '', schedule.end_date)
    assert schedule.days == 0, format_error("Unexpected schedule days", '0', schedule.days)
  end

  test "advanced monthly schedule" do
    current_user = users(:bas)

    params = {
      type: 'advanced',
      name: 'test schedule',
      start_date: '17-Mar-2019',
      timezone: 'Europe/London',
      schedule: 'monthly',
      run_every: '1',
      days: 'specific',
      days2: 'day',
      dates_picked: ' 28',
      weekday_mon: '0',
      weekday_tue: '0',
      weekday_wed: '0',
      weekday_thu: '0',
      weekday_fri: '0',
      weekday_sat: '1',
      weekday_sun: '1',
      end_date: '20-Feb-2020',
      weekday_exclude_mon: '0',
      weekday_exclude_tue: '0',
      weekday_exclude_wed: '0',
      weekday_exclude_thu: '0',
      weekday_exclude_fri: '0',
      weekday_exclude_sat: '1',
      weekday_exclude_sun: '1',
      dates_picked_exclude: '',
      exclusion_met1: 'previous',
      exclusion_met2: 'fri'
    }

    schedule = Schedule.create_from_form({schedule: params}, current_user)
    assert schedule.name == 'test schedule', format_error("Unexpected schedule name", 'test schedule', schedule.name)
    assert schedule.days_month == 'specific', format_error("Unexpected schedule days_month", 'specific', schedule.days_month)
    assert schedule.end_date == '2020-02-20'.to_date, format_error("Unexpected schedule end date", '2020-02-20', schedule.end_date)
    assert schedule.days == 268435456, format_error("Unexpected schedule days", '268435456', schedule.days)
  end

  test "next occurrence" do
    current_user = users(:bas)

    params = {
      type: 'advanced',
      name: 'test schedule',
      start_date: '17-Mar-2019',
      timezone: 'Europe/London',
      schedule: 'monthly',
      run_every: '1',
      days: 'specific',
      days2: 'day',
      dates_picked: ' 28',
      weekday_mon: '0',
      weekday_tue: '0',
      weekday_wed: '0',
      weekday_thu: '0',
      weekday_fri: '0',
      weekday_sat: '1',
      weekday_sun: '1',
      end_date: '20-Feb-2020',
      weekday_exclude_mon: '0',
      weekday_exclude_tue: '0',
      weekday_exclude_wed: '0',
      weekday_exclude_thu: '0',
      weekday_exclude_fri: '0',
      weekday_exclude_sat: '1',
      weekday_exclude_sun: '1',
      dates_picked_exclude: '',
      exclusion_met1: 'previous',
      exclusion_met2: 'fri'
    }

    schedule = Schedule.create_from_form({schedule: params}, current_user)

    assert Schedule.next_occurrence(schedule) == '2019-03-28'.to_date
  end

end
