class Schedule
  class RunSchedules

    def initialize(datetime=nil, schedules=nil)
      @datetime = datetime
      @datetime ||= Time.now
      schedules ||= Schedule.where("next_occurrence_utc <= ?", @datetime)

      @schedules = schedules
    end

    def perform
      transactions = []
      @schedules.each do |s|
        transactions += run_schedule(s)

      end

      return transactions
    end

private

    def run_schedule(schedule)
      transactions = get_scheduled_transactions(schedule)
      update_next_rundate(schedule)

      return transactions
    end

    def get_scheduled_transactions(schedule)
      sch_transactions = schedule.user_transactions
      transactions = []
      sch_transactions.each do |st|
        transaction = Transaction.create_from_schedule(st, schedule)
        transactions += transaction
      end

      return transactions
    end

    def update_next_rundate(schedule)
      tz = TZInfo::Timezone.get(schedule.timezone)

      next_occurrence = Schedule.next_occurrence(schedule, @datetime.to_date, false, true)
      schedule.next_occurrence = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?
      schedule.next_occurrence_utc = next_occurrence

    end

  end
end