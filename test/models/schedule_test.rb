# == Schema Information
#
# Table name: schedules
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  transaction_id    :bigint(8)
#  account_id        :bigint(8)
#  start_date        :date
#  end_date          :date
#  period            :string(255)
#  period_day        :integer
#  period_occurences :integer
#  exception_days    :string(255)
#  exception_rule    :string(255)
#  next_occurrence   :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
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
      schedule: 'Monthly',
      run_every: '1',
      days: 'Specific dates',
      days2: 'Day',
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
      exclusion_met1: 'Run on the previous ...'
      exclusion_met2: 'Friday'
    }
  end

end
