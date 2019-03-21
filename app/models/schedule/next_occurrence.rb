class Schedule
  class NextOccurrence

    def initialize(schedule, date=nil)
      @schedule = schedule
      @date = date

      puts "\ninitialized with date #{@date}"
    end

    def perform
      puts "\n  ---------- PERFORM START ----------"
      # set the timezone to that of the schedule
      tz = TZInfo::Timezone.get(@schedule.timezone)

      # if no date given, set date to today
      @date ||= tz.utc_to_local(Time.now).to_date
      puts "  Date after timezone set: #{@date}"

      # check if the schedule expired
      return nil if schedule_expired

      # return the date if it runs on this date and is not excluded
      if runs_on_date
        if !is_excluded
          puts "  #{@date} runs on first try"
        else
          puts "  #{@date} runs on first try, but was excluded"
        end
      end

      puts "\n  ---------- PERFORM END ----------"
    end

    # returns true if the @date is greater than the schedule's end date, meaning that the schedule has expired
    def schedule_expired
      return @schedule.end_date && @date > @schedule.end_date
    end

    def is_excluded

    end

    def runs_on_date
      puts "\n    ---------- RUNS_ON_DATE START ----------"
      puts "    checking if schedule runs at #{@date}"
      puts "      schedule period = #{@schedule.period}"

      returns = false
      # if the schedule hasn't started yet
      returns = false if @date < @schedule.start_date

      case @schedule.period
      when 'days'

        puts "        (@date - @schedule.start_date) % @schedule.period_num = #{((@date - @schedule.start_date) % @schedule.period_num).to_i}"
        returns = (@date - @schedule.start_date) % @schedule.period_num == 0

      when 'weeks'

        

      when 'months'

      when 'years'

      else

      end

      puts "\n    ---------- RUNS_ON_DATE END ----------"
      return returns
    end

  end
end