class Schedule
  class RunSchedules

    def initialize(datetime=nil, schedules=nil)
      @datetime = datetime
      @datetime ||= Time.now.utc
      schedules ||= Schedule.where("next_occurrence_utc <= ?", @datetime)

      @schedules = schedules
    end

    def perform
      transactions = []
      @schedules.each do |s|
        # check if the schedule is paused
        unless s.pause_until_utc.nil?
          if s.pause_until_utc <= Time.now.utc
            s.pause_until_utc = nil
            s.pause_until = nil
            s.save
          else
            next
          end
        end

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
      return [] unless schedule.is_active
      sch_transactions = schedule.user_transactions
      transactions = []
      sch_transactions.each do |st|
        if st.parent_id.nil?
          if !st.transfer_transaction_id.nil? && st.direction == -1
            next
          end

          # check if the transaction wasn't already ran manually
          ran_transaction = st.user.transactions.where(:schedule_id => schedule.id, :schedule_period_id => schedule.current_period_id, :scheduled_transaction_id => st.id).take
          unless ran_transaction
            transaction = Transaction.create_from_schedule(st, schedule, st.id)
            transactions += transaction
          end
        end
      end

      schedule.current_period_id += 1
      schedule.save

      return transactions
    end

    def update_next_rundate(schedule)
      tz = TZInfo::Timezone.get(schedule.timezone)

      # record the occurrence
      occurrence = ScheduleOccurrence.new({
        schedule_id: schedule.id,
        occurrence_utc: tz.utc_to_local(schedule.next_occurrence.to_datetime),
        occurrence_local: schedule.next_occurrence
      })
      occurrence.save

      next_occurrence = Schedule.next_occurrence(schedule, @datetime.to_date + 1, false, true)
      schedule.next_occurrence = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?
      schedule.next_occurrence_utc = next_occurrence

      schedule.save!
    end

  end
end