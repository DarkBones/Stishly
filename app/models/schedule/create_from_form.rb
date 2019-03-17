class Schedule
  class CreateFromForm
    
    def initialize(params, current_user)
      @params = params[:schedule]
      @current_user = current_user

      @excluding = false
    end

    def perform
      schedule_params = {
        name: @params[:name],
        start_date: @params[:start_date].to_date,
        end_date: get_end_date,
        period: get_period,
        period_num: @params[:run_every],
        days: get_days,
        days_month: get_days_month,
        days_month_day: get_month_day,
        days_exclude: get_days_exclude,
        exclusion_met: get_exclusion_met,
        exclusion_met_day: get_exclusion_met_day,
        timezone: @params[:timezone]
      }

      #schedule = Schedule.new(schedule_params)
      schedule = @current_user.schedules.new(schedule_params)
      return schedule
    end

    def get_end_date
      if @params[:end_date].length > 0 && @params[:type] == 'advanced'
        return @params[:end_date].to_date
      else
        return ''
      end
    end

    def get_days_month
      days_month = ''
      if @params[:type] == 'advanced'
        days_month = @params[:days]
      end
      return days_month
    end

    def get_month_day
      month_day = ''
      if @params[:schedule] == 'monthly' && @params[:days] != 'specific' && @params[:type] == 'advanced'
        month_day = @params[:days2]
      end
      return month_day
    end

    def get_exclusion_met
      met = ''

      if @params[:schedule] == 'monthly' && @excluding == true && @params[:type] == 'advanced'
        met = @params[:exclusion_met1]
      end

      return met
    end

    def get_exclusion_met_day
      met = ''

      if @params[:schedule] == 'monthly' && @excluding == true && @params[:type] == 'advanced'
        met = @params[:exclusion_met2]
      end

      return met
    end

    def get_days_exclude
      bitmask = 0b0
      if @params[:type] == 'advanced'
        if @params[:schedule] == 'monthly'
          
          if @params[:days] == 'specific'
            bitmask = get_weekday_bitmask(['weekday_exclude_mon',
            'weekday_exclude_tue',
            'weekday_exclude_wed',
            'weekday_exclude_thu',
            'weekday_exclude_fri',
            'weekday_exclude_sat',
            'weekday_exclude_sun'])
          else
            bitmask = get_month_bitmask(@params[:dates_picked_exclude])
          end

        end

        @excluding = true if bitmask > 0
      end

      return bitmask
    end

    def get_period
      result = case @params[:schedule]
      when 'daily' then 'days'
      when 'weekly' then 'weeks'
      when 'monthly' then 'months'
      else 'years'
      end

      return result
    end

    def get_days

      bitmask = 0b0

      if @params[:type] == 'advanced'
        if @params[:schedule] == 'weekly'
          bitmask = get_weekday_bitmask(['weekday_mon',
            'weekday_tue',
            'weekday_wed',
            'weekday_thu',
            'weekday_fri',
            'weekday_sat',
            'weekday_sun'])
        elsif @params[:schedule] == 'monthly' && @params[:days] == 'specific'
          bitmask = get_month_bitmask(@params[:dates_picked])
        end
      end

      return bitmask
    end

    def get_weekday_bitmask(weekdays)
      bitmask = 0b0
      weekdays.each_with_index do |d, i|
        if @params[d.to_sym] == '1'
          bitmask = bitmask | (1 << i)
        end
      end
      return bitmask
    end

    def get_month_bitmask(days)
      days = days.strip
      days = days.split(' ')

      bitmask = 0b0
      days.each do |d|
        bitmask = bitmask | (1 << d.to_i)
      end

      return bitmask
    end

  end
end