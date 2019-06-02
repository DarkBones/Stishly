require 'test_helper'

class ScheduleOverlapTest < ActiveSupport::TestCase
  
  test "overlap payday with daily" do
    current_user = users(:schedules_overlap)
    schedule = schedules(:overlap_main)

    Schedule.period_range(schedule, Date.new(2019, 3, 25))
  end

end