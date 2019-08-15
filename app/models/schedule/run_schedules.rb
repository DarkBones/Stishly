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

      deactivate_ending_schedules

      return transactions
    end

private

    def deactivate_ending_schedules
      schedules = Schedule.where("is_active = true AND end_date <= ?", @datetime)
      schedules.each do |schedule|
        schedule.next_occurrence = nil
        schedule.is_active = false
        schedule.save!
      end
    end

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
          ran_transaction = st.user.transactions.where(
            :schedule_id => schedule.id, 
            :schedule_period_id => schedule.current_period_id, 
            :scheduled_transaction_id => st.id,
            :is_scheduled => false).take

          next if ran_transaction

          cancelled_transaction = st.user.transactions.where(
            :schedule_id => schedule.id, 
            :schedule_period_id => schedule.current_period_id, 
            :scheduled_transaction_id => st.id,
            :is_cancelled => true).take

          next if cancelled_transaction

          edited_transactions = st.user.transactions.where(
            :schedule_id => schedule.id, 
            :schedule_period_id => schedule.current_period_id, 
            :scheduled_transaction_id => st.id,
            :is_scheduled => true)
          edited_transaction = nil
          unless edited_transactions.nil?
            edited_transactions.each do |et|
              if et.transfer_transaction_id.nil? || (!et.transfer_transaction_id.nil? && et.direction == -1)
                st = et
              end
            end
          end

          transaction = Transaction.create_from_schedule(st, schedule, st.id)
          transactions += transaction
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

      next_occurrence = Schedule.next_occurrence(schedule, date: @datetime.to_date + 1, return_datetime: true)
      schedule.next_occurrence = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?
      schedule.next_occurrence_utc = next_occurrence

      schedule.save!
    end

  end
end