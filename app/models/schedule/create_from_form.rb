class Schedule
  class CreateFromForm
    
    def initialize(params, current_user, testing=false)
      @params = params[:schedule]
      @current_user = current_user

      @excluding = false
      @testing = testing
    end

    def perform
      @params[:name] = sanitise_name(@params[:name])
      @params[:run_every] = sanitise_period_num(@params[:run_every])
      error = check_errors
      return error[:message] if error[:is_error]

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
        timezone: @params[:timezone],
        is_active: get_is_active
      }

      #schedule = Schedule.new(schedule_params)
      schedule = @current_user.schedules.new(schedule_params)
      return schedule
    end

private

    def sanitise_name(name_str)
      # don't allow dots in schedule name
      return name_str.gsub '.', ''
    end

    # takes run_every as string, and returns a positive integer
    def sanitise_period_num(period_num)
      if period_num.respond_to? :to_i
        period_num = period_num.to_i
        if period_num < 1
          return 1
        else
          return period_num
        end
      else
        return 1
      end
    end

    # checks if there are any errors. Returns a message and a boolean whether an error has been found
    def check_errors
      return {message: I18n.t('schedule.failure.invalid_name'), is_error: true} if @params[:name].length == 0

      # check if start_date is valid
      return {message: I18n.t('schedule.failure.invalid_date'), is_error: true} if valid_date(@params[:start_date]) == false

      # if the end_date format is invalid, just leave it empty
      @params[:end_date] = '' if valid_date(@params[:start_date]) == false

      # check if the schedule already exists
      return {message: I18n.t('schedule.failure.already_exists'), is_error: true} if is_duplicate(@params[:name])

      # no errors found
      return {message: 'no errors', is_error: false}

    end

    # returns the end date if the schedule type is 'advanced'
    def get_end_date
      if @params[:end_date].length > 0 && @params[:type] == 'advanced'
        return @params[:end_date].to_date
      else
        return ''
      end
    end

    # returns the period (days / weeks / months / years)
    def get_period
      result = case @params[:schedule]
      when 'daily' then 'days'
      when 'weekly' then 'weeks'
      when 'monthly' then 'months'
      else 'years'
      end

      return result
    end

    # returns the days bitmask
    def get_days

      return 0b0 if @params[:type] != 'advanced'

      return get_weekday_bitmask(['weekday_sun', 'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat']) if @params[:schedule] == 'weekly'

      return get_month_bitmask(@params[:dates_picked]) if @params[:schedule] == 'monthly' && @params[:days] == 'specific'

      return get_unspecific_days

    end

    def get_unspecific_days
      if @params[:schedule] == 'monthly' && @params[:days] != 'specific' && @params[:days2] != 'day'
        weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
        return 0b0 | (1 << weekdays.index(@params[:days2]))
      end

      return 0
    end

    def get_days_month
      days_month = ''
      if @params[:type] == 'advanced'
        days_month = @params[:days]
      end
      return days_month
    end

    def get_month_day
      weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']

      month_day = 0
      if @params[:schedule] == 'monthly' && @params[:days] != 'specific' && @params[:type] == 'advanced'
        month_day = weekdays.index(@params[:days2])
      end
      return month_day
    end

    def get_days_exclude
      bitmask = 0b0
      if @params[:type] == 'advanced'
        if @params[:schedule] == 'monthly'
          
          if @params[:days] == 'specific' || (@params[:days] != 'specific' && @params[:days2] == 'day')
            bitmask = get_weekday_bitmask([
              'weekday_exclude_sun',
              'weekday_exclude_mon',
              'weekday_exclude_tue',
              'weekday_exclude_wed',
              'weekday_exclude_thu',
              'weekday_exclude_fri',
              'weekday_exclude_sat'])
          else
            bitmask = get_month_bitmask(@params[:dates_picked_exclude])
          end

        end

        @excluding = true if bitmask > 0
      end

      return bitmask
    end

    def get_exclusion_met
      met = ''

      if @params[:schedule] == 'monthly' && @excluding == true && @params[:type] == 'advanced'
        met = @params[:exclusion_met1]
      end

      return met
    end

    def get_exclusion_met_day
      weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']

      met = 0

      if @params[:schedule] == 'monthly' && @excluding == true && @params[:type] == 'advanced'
        met = weekdays.index(@params[:exclusion_met2])
      end

      return met
    end

    # validates of the schedule is currently active (hasn't expired)
    def get_is_active
      return Time.now.to_date < @params[:end_date].to_date if @params[:end_date].length >= 11
      return true
    end

    # validates a given date (string) is in the correct format
    def valid_date(date)
      date_regex = APP_CONFIG['ui']['dates']['regex']

      return !/#{date_regex}/.match(date.downcase).nil?
    end

    # validates if a schedule with the same name already exists
    def is_duplicate(name_str)
      schedules = @current_user.schedules.where("LOWER(schedules.name) LIKE LOWER(?)", name_str)
      if schedules && !testing
        return true
      else
        return false
      end
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

      if bitmask == 0
        bitmask = 0b0
        bitmask = bitmask | (1 << @params[:start_date].to_date.day)
      end

      return bitmask
    end

  end
end
