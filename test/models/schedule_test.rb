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
      
    }
  end

end
