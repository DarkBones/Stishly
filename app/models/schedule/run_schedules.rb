class Schedule
  class RunSchedules

    def initialize(datetime=nil, schedules=nil)
      datetime ||= Time.now
      schedules ||= Schedule.where("next_occurrence_utc <= ?", datetime)

      @schedules = schedules
    end

    def perform
      @schedules.each do |s|

      end
    end

private

    def run_schedule(schedule)

    end

  end
end