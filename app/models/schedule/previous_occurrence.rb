class Schedule
  class PreviousOccurrence

    def initialize(schedule, date=nil)
      @schedule = schedule
      @date = date

    end

    def perform
      # set the timezone to that of the schedule
      tz = TZInfo::Timezone.get(@schedule.timezone)

      # if no date given, set date to today
      @date ||= tz.utc_to_local(Time.now).to_date

      previous_date = find_previous_date

      return previous_date
    end

private
    
    def find_previous_date
      case @schedule.period
      when 'days'
        return find_previous_day
      when 'weeks'
        return find_previous_week
      when 'months'
        return find_previous_month
      when 'years'
        return find_previous_year
      else
        return nil
      end
    end

    def find_previous_day
    end

    def find_previous_week
    end

    def find_previous_month
    end

    def find_previous_year
    end

  end
end