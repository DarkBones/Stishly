require 'test_helper'

class ScheduleOverlapTest < ActiveSupport::TestCase
  
  test "overlap payday with daily" do
    current_user = users(:schedules_overlap)

    puts current_user.id
  end

end