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
      day = @date - ((@date - @schedule.start_date) % @schedule.period_num)
      return day
    end

    def find_previous_week
      if @schedule.days == 0
        date = @date - ((@date.wday - @schedule.start_date.wday) % 7) - (7 * ((@date - @schedule.start_date) % @schedule.period_num))
        return date
      else
        #puts "#{@date} - #{find_next_in_bitmask(@schedule.days, @date.wday, 7, true)}"
        date = @date - find_next_in_bitmask(@schedule.days, ((@date.wday + 1) % 7), 7, true)

        #puts ((@date.wday + 1) % 7)
        if ((@date.wday + 1) % 7) < first_in_bitmask(@schedule.days)
          puts "#{@date} - #{periods_to_add} = #{@date - (periods_to_add * 7)}"
          date -= periods_to_add * 7
          puts date
        end

        return date
      end
    end

    def find_previous_month
    end

    def find_previous_year
    end

    # calculates how many periods (weeks / months) to add
    def periods_to_add(date=nil)
      date ||= @date
      case @schedule.period
      when 'weeks'
        weeks_to_add = 0
        #if date.wday >= bitmask(@schedule.days).length
          weeks_since_startdate = (date - @schedule.start_date) / 7
          weeks_to_add = (@schedule.period_num - (weeks_since_startdate % @schedule.period_num)).to_i
        #end

        return weeks_to_add
      when 'months'
        days = get_days_month(date)

        months_to_add = 0
        if date.day >= bitmask(days).length-1 || date.day <= bitmask(days).index('1')
          months_since_startdate = (date.year * 12 + date.month) - (@schedule.start_date.year * 12 + @schedule.start_date.month)
          
          if (months_since_startdate % @schedule.period_num) > 0
            months_to_add = @schedule.period_num - (months_since_startdate % @schedule.period_num)
          end
        end

        return months_to_add

      end
    end

    # returns the bitmask as array from an integer
    def bitmask(int)
      return int.to_s(2).reverse.split('')
    end

    # finds the first occurrence in a bitmask
    def first_in_bitmask(bits)
      return 0 if bits == 0

      mask = bitmask(bits)

      mask.each_with_index do |b, idx|
        if mask[idx] == '1'
          return idx
          break
        end
      end
    end

    # finds the next occurrence in a bitmask
    def find_next_in_bitmask(bits, day, mask_length=nil, reverse=false)
      return 0 if bits == 0

      mask = bitmask(bits)

      if mask_length != nil
        while mask.length < mask_length do
          mask.push('0')
        end
      end

      if reverse
        day = mask.length - day
        mask = mask.reverse
      end

      mask.each_with_index do |_b, idx|
        if mask[(idx + day) % mask.length] == '1'
          return idx
        end
      end
    end

  end
end