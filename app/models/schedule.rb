# == Schema Information
#
# Table name: schedules
#
#  id                :bigint(8)        not null, primary key
#  name              :string(255)
#  user_id           :bigint(8)
#  start_date        :date
#  end_date          :date
#  period            :string(255)
#  period_num        :integer
#  days              :integer
#  days_month        :string(255)
#  days_month_day    :string(255)
#  days_exclude      :integer
#  exclusion_met     :string(255)
#  exclusion_met_day :string(255)
#  timezone          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_active         :boolean          default(TRUE)
#

class Schedule < ApplicationRecord
  validates :name, :start_date, :user_id, presence: true

  belongs_to :user
  has_many :schedule_joins
  has_many :transactions, through: :schedule_joins

  def self.create_from_form(params, current_user)
    schedule = CreateFromForm.new(params, current_user).perform()
    return schedule
  end

  def self.next_occurrence(schedule, date=nil)
    # set the date
    if date == nil
      tz = TZInfo::Timezone.get(schedule.timezone)
      date = tz.utc_to_local(Time.now).to_date
    end

    # if the schedule expired
    if schedule.end_date && date > schedule.end_date
      puts 'expired'
      return nil
    end

    weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']

    # check if the schedule runs on the current date
    runs = check_match(schedule, date)
    excluded = is_excluded(schedule, date)

    # return the date if the schedule runs on the current date
    return date if runs == true && excluded == false

    if excluded == true
      if schedule.exclusion_met == 'next'
        return date + (weekdays.index(schedule.exclusion_met_day) - date.wday) % 7
      end
    end

    # find the next date
    if schedule.period == 'days'
      return date + schedule.period_num
    elsif schedule.period == 'weeks' || schedule.period == 'months'
      while true do
        date += 1
        if schedule.end_date && date > schedule.end_date
          puts 'expired'
          return nil
        end
        if check_match(schedule, date) == true
          if schedule.period == 'weeks'
            return date
            break
          else
            if is_excluded(schedule, date) == false
              return date
              break
            else
              if schedule.exclusion_met == 'next'
                return date + (weekdays.index(schedule.exclusion_met_day) - date.wday) % 7
              elsif schedule.exclusion_met == 'previous'
                return date - (date.wday - weekdays.index(schedule.exclusion_met_day)) % 7
              end
            end
          end
        end
      end
    else
      if date.day < schedule.start_date.day && date.month < schedule.start_date.month
        year += schedule.period_num
      end
      return Date.new(year, schedule.start_date.month, schedule.start_date.day)
    end

=begin

    # find the next year
    year = date.year
    if schedule.period == 'years'
      if date.day < schedule.start_date.day && date.month < schedule.start_date.month
        year += schedule.period_num
      end
    elsif schedule.period == 'months'


    # find the next month


    # find the next day


    # check if the next date is less than the schedule's end date


    # return nil if no next occurrence is scheduled


    # return the next scheduled run date

=end
  end

private

  def self.is_excluded(schedule, date)
    if schedule.period != 'months'
      return false
    end

    days_bitmask_exclude = schedule.days_exclude.to_s(2).reverse.split('')
    if schedule.days_month == 'specific'
      return days_bitmask_exclude[(date.wday - 1) % 7] == '1'
    else
      return days_bitmask_exclude[(date.day)] == '1'
    end

  end
  
  # check if a given date matches a schedule
  # returns true if the schedule will run on the given date
  # returns false if the schedule will not run on the given date
  def self.check_match(schedule, date)
    # if the schedule hasn't started yet
    if date < schedule.start_date
      return false
    end

    # if the schedule expired
    if schedule.end_date && date > schedule.end_date
      return false
    end

    if schedule.period == 'days'

      days_since_start_date = date - schedule.start_date
      return days_since_start_date % schedule.period_num == 0

    elsif schedule.period == 'weeks'

      weeks_since_start_date = ((date - schedule.start_date) / 7)
      if weeks_since_start_date.floor % schedule.period_num == 0
        
        if schedule.days == 0
          return weeks_since_start_date.to_i == weeks_since_start_date
        else
          weekdays_bitmask = schedule.days.to_s(2).reverse.split('')
          current_weekday = (date.wday - 1) % 7
          return weekdays_bitmask[current_weekday] == '1'
        end

      else
        return false
      end

    elsif schedule.period == 'months'

      months_since_start_date = date.month - schedule.start_date.month
      if months_since_start_date % schedule.period_num != 0
        return false
      else

        if schedule.days == 0 && schedule.days_month == 'specific'
          return date.day == schedule.start_date.day
        else
          if schedule.days_month == 'specific'
            days_bitmask = schedule.days.to_s(2).reverse.split('')

            return days_bitmask[date.day] == '1'
          else
            weekdays = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
            values = ['first', 'second', 'third', 'fourth']

            if schedule.days_month_day != 'day'
              weekday = weekdays.index(schedule.days_month_day)
              
              if schedule.days_month == 'last'
                d = Date.new(date.year, date.month, -1)
                d -= (d.wday - weekday) % 7
                return date == d
              else
                d = Date.new(date.year, date.month, 1)
                d += (weekday - d.wday) % 7

                d += (7 * values.index(schedule.days_month))
                if d.month == date.month
                  return d == date
                else
                  return false
                end
              end
            else
              d = Date.new(date.year, date.month, values.index(schedule.days_month)+1)
              return d == date
            end
          end


        end

      end

    else
      years_since_start_date = date.year - schedule.start_date.year
      return years_since_start_date % schedule.period_num == 0
    end
  end

end











