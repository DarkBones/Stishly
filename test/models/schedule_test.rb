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

  test "Schedule with negative period_num" do
    current_user = users(:bas)

    params = {
      name: "test schedule",
      start_date: Time.now,
      period: "month",
      period_num: -1,
      days: 0b0 | (1 << 28),
      days_exclude: 0b0 | (1 << 5) | (1 << 6),
      exclusion_met: "previous",
      exclusion_met_day: "fri",
      timezone: "Europe/London"
    }

    schedule = current_user.schedules.build(params)
    assert_not schedule.save, "Saved schedule with negative period_num"
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
    start_date = Date.new(2019, 03, 25)

    # simple daily schedule
    params = reset_params
    params[:schedule] = 'daily'

    schedule = Schedule.create_from_form({schedule: params}, current_user)
    dates = [
      '2019-03-25',
      '2019-03-26',
      '2019-03-27',
      '2019-03-28',
      '2019-03-29',
      '2019-03-30',
      '2019-03-31',
      '2019-04-01',
      '2019-04-02',
      '2019-04-03'
    ]
    assert_dates(schedule, dates, start_date, params)

    # simple every three days
    params[:run_every] = '3'
    dates = [
      '2019-03-25',
      '2019-03-28',
      '2019-03-31',
      '2019-04-03'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced every day, with end date
    params[:run_every] = '1'
    params[:type] = 'advanced'
    params[:end_date] = '02-Apr-2019'
    dates = [
      '2019-03-25',
      '2019-03-26',
      '2019-03-27',
      '2019-03-28',
      '2019-03-29',
      '2019-03-30',
      '2019-03-31',
      '2019-04-01',
      '2019-04-02',
      nil
    ]
    assert_dates(schedule, dates, start_date, params)

    params = reset_params
    # simple every week
    params[:schedule] = 'weekly'
    dates = [
      '2019-03-25',
      '2019-04-01',
      '2019-04-08',
      '2019-04-15',
      '2019-04-22',
      '2019-04-29',
      '2019-05-06'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced every week on Fridays
    params[:type] = 'advanced'
    params[:weekday_fri] = '1'
    dates = [
      '2019-03-29',
      '2019-04-05',
      '2019-04-12',
      '2019-04-19',
      '2019-04-26',
      '2019-05-03'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced every week on Fridays and Wednesdays
    params[:type] = 'advanced'
    params[:weekday_wed] = '1'
    dates = [
      '2019-03-27',
      '2019-03-29',
      '2019-04-03',
      '2019-04-05',
      '2019-04-10',
      '2019-04-12',
      '2019-04-17'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced every 3 weeks on Fridays and Wednesdays
    params[:run_every] = '3'
    dates = [
      '2019-03-27',
      '2019-03-29',
      '2019-04-17',
      '2019-04-19',
      '2019-05-08',
      '2019-05-10'
    ]
    assert_dates(schedule, dates, start_date, params)

    params = reset_params
    # simple monthly every month
    params[:schedule] = 'monthly'
    dates = [
      '2019-03-25',
      '2019-04-25',
      '2019-05-25',
      '2019-06-25',
      '2019-07-25',
      '2019-08-25',
      '2019-09-25',
      '2019-10-25',
      '2019-11-25',
      '2019-12-25',
      '2020-01-25'
    ]
    assert_dates(schedule, dates, start_date, params)

    # simple monthly every two months
    params[:run_every] = '2'
    dates = [
      '2019-03-25',
      '2019-05-25',
      '2019-07-25',
      '2019-09-25',
      '2019-11-25',
      '2020-01-25'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the 28th
    params[:run_every] = '1'
    params[:dates_picked] = ' 28'
    dates = [
      '2019-03-28',
      '2019-04-28',
      '2019-05-28',
      '2019-06-28',
      '2019-07-28',
      '2019-08-28',
      '2019-09-28',
      '2019-10-28',
      '2019-11-28',
      '2019-12-28',
      '2020-01-28'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every two months on the 28th and on the 5th
    params[:run_every] = '2'
    params[:dates_picked] = ' 5 28'
    dates = [
      '2019-03-28',
      '2019-05-05',
      '2019-05-28',
      '2019-07-05',
      '2019-07-28',
      '2019-09-05',
      '2019-09-28'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every two months on the 28th and on the 5th, but not on weekends or Thursdays
    params[:weekday_exclude_thu] = '1'
    params[:weekday_exclude_sat] = '1'
    params[:weekday_exclude_sun] = '1'
    params[:exclusion_met1] = 'cancel'
    dates = [
      '2019-05-28',
      '2019-07-05',
      '2019-11-05',
      '2020-01-28',
      '2020-05-05'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the 28th and on the 5th, but not on weekends. If excluded, run on the previous Thursday
    params[:run_every] = '1'
    params[:weekday_exclude_thu] = '0'
    params[:weekday_exclude_sat] = '1'
    params[:weekday_exclude_sun] = '1'
    params[:exclusion_met1] = 'previous'
    params[:exclusion_met2] = 'thu'
    dates = [
      '2019-03-28',
      '2019-04-05',
      '2019-04-25',
      '2019-05-02',
      '2019-05-28',
      '2019-06-05',
      '2019-06-28',
      '2019-07-05',
      '2019-07-25',
      '2019-08-05',
      '2019-08-28',
      '2019-09-05',
      '2019-09-26',
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the 28th and on the 5th, but not on weekends. If excluded, run on the next Monday
    params[:exclusion_met1] = 'next'
    params[:exclusion_met2] = 'mon'
    dates = [
      '2019-03-28',
      '2019-04-05',
      '2019-04-29',
      '2019-05-06',
      '2019-05-28',
      '2019-06-05',
      '2019-06-28',
      '2019-07-05',
      '2019-07-29',
      '2019-08-05',
      '2019-08-28',
      '2019-09-05',
      '2019-09-30'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last Friday
    params[:weekday_exclude_sat] = '0'
    params[:weekday_exclude_sun] = '0'
    params[:dates_picked] = ''
    params[:exclusion_met1] = ''
    params[:exclusion_met2] = ''
    params[:days] = 'last'
    params[:days2] = 'fri'
    dates = [
      '2019-03-29',
      '2019-04-26',
      '2019-05-31',
      '2019-06-28',
      '2019-07-26',
      '2019-08-30',
      '2019-09-27'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last Friday, except on the 26th
    params[:exclusion_met1] = 'cancel'
    params[:dates_picked_exclude] = ' 26'
    dates = [
      '2019-03-29',
      '2019-05-31',
      '2019-06-28',
      '2019-08-30',
      '2019-09-27'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last Friday, except on the 26th. Run on previous Wednesday if excluded
    params[:exclusion_met1] = 'previous'
    params[:exclusion_met1] = 'wed'
    dates = [
      '2019-03-29',
      '2019-04-24',
      '2019-05-31',
      '2019-06-28',
      '2019-07-24',
      '2019-08-30',
      '2019-09-27'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last day
    params[:days2] = 'day'
    dates = [
      '2019-03-31',
      '2019-04-30',
      '2019-05-31',
      '2019-06-30',
      '2019-07-31',
      '2019-08-31',
      '2019-09-30'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last day, except on weekends
    params[:weekday_exclude_sat] = '1'
    params[:weekday_exclude_sun] = '1'
    params[:exclusion_met1] = 'cancel'
    params[:exclusion_met1] = ''
    params[:dates_picked_exclude] = ''
    dates = [
      '2019-04-30',
      '2019-05-31',
      '2019-07-31',
      '2019-09-30'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last day, except on weekends. Run the previous Friday if excluded
    params[:exclusion_met1] = 'previous'
    params[:exclusion_met2] = 'fri'
    dates = [
      '2019-03-29',
      '2019-04-30',
      '2019-05-31',
      '2019-06-28',
      '2019-07-31',
      '2019-08-30',
      '2019-09-30'
    ]
    assert_dates(schedule, dates, start_date, params)

    # advanced monthly every month on the last day, except on weekends. Run the next Friday if excluded
    params[:exclusion_met1] = 'next'
    dates = [
      '2019-04-05',
      '2019-04-30',
      '2019-05-31',
      '2019-07-05',
      '2019-07-31',
      '2019-09-06',
      '2019-09-30'
    ]
    assert_dates(schedule, dates, start_date, params)

    params = reset_params
    # simple annually every 5 years
    params[:schedule] = 'annually'
    params[:run_every] = '5'
    dates = [
      '2019-03-25',
      '2024-03-25',
      '2029-03-25',
      '2034-03-25',
      '2039-03-25',
      '2044-03-25',
    ]
    assert_dates(schedule, dates, start_date, params)
  end

  def assert_dates(schedule, dates, start_date, params)
    next_occurrence = start_date
    for i in 0...dates.length do
      date = dates[i]
      next_occurrence = Schedule.next_occurrence(next_occurrence + 1)

      assert date.to_s == next_occurrence.to_s, format_error("Unexpected next occurrence", date.to_s, next_occurrence.to_s + "\n\nSchedule Params:\n#{params.to_yaml}")
    end
  end

  def reset_params
    return {
      type: 'simple',
      name: 'test schedule',
      start_date: '17-Mar-2019',
      timezone: 'Europe/London',
      schedule: '',
      run_every: '1',
      days: '',
      days2: '',
      dates_picked: '',
      weekday_mon: '0',
      weekday_tue: '0',
      weekday_wed: '0',
      weekday_thu: '0',
      weekday_fri: '0',
      weekday_sat: '0',
      weekday_sun: '0',
      end_date: '',
      weekday_exclude_mon: '0',
      weekday_exclude_tue: '0',
      weekday_exclude_wed: '0',
      weekday_exclude_thu: '0',
      weekday_exclude_fri: '0',
      weekday_exclude_sat: '0',
      weekday_exclude_sun: '0',
      dates_picked_exclude: '',
      exclusion_met1: '',
      exclusion_met2: ''
    }
  end

end
