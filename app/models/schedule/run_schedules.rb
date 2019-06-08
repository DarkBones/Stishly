class Schedule
  class RunSchedules

    def initialize(datetime=nil, schedules=nil)
      datetime ||= Time.now
      schedules ||= Schedule.where("next_occurrence_utc <= ?", datetime)

      @schedules = schedules
    end

    def perform
      transactions = []
      @schedules.each do |s|
        transactions += run_schedule(s)
      end

      return nil
    end

private

    def run_schedule(schedule)
      transactions = schedule.user_transactions
      transactions.each do |t|
        puts t.description
      end

      return transactions
    end

  end
end