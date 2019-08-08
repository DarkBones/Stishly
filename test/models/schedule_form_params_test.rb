# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint           not null, primary key
#  name                :string(255)
#  user_id             :bigint
#  start_date          :date
#  end_date            :date
#  period              :string(255)
#  period_num          :integer          default(0)
#  days                :integer          default(0)
#  days_month          :string(255)
#  days_month_day      :integer
#  days_exclude        :integer
#  exclusion_met       :string(255)
#  exclusion_met_day   :integer
#  timezone            :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  is_active           :boolean          default(TRUE)
#  next_occurrence     :date
#  last_occurrence     :date
#  next_occurrence_utc :datetime
#  type_of             :string(255)      default("schedule")
#  pause_until         :date
#  pause_until_utc     :datetime
#  current_period_id   :integer          default(0)
#

require 'test_helper'

class ScheduleFormParamsTest < ActiveSupport::TestCase
=begin
  test "Simple daily" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'daily'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Simple weekly" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'weekly'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Simple monthly" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'monthly'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Simple annually" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'annually'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Advanced weekly Monday and Friday" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'weekly'
    params[:weekday_mon] = '1'
    params[:weekday_fri] = '1'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Advanced weekly every day" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'weekly'
    params[:weekday_mon] = '1'
    params[:weekday_tue] = '1'
    params[:weekday_wed] = '1'
    params[:weekday_thu] = '1'
    params[:weekday_fri] = '1'
    params[:weekday_sat] = '1'
    params[:weekday_sun] = '1'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Advanced monthly 28th" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'monthly'
    params[:days] = 'specific'
    params[:dates_picked] = '28'

    schedule = Schedule.create_from_form(params, current_user, true)

    puts Schedule.get_form_params(schedule).to_yaml
  end

  test "Advanced monthly 28th unless weekends" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'monthly'
    params[:days] = 'specific'
    params[:dates_picked] = '28'
    params[:weekday_exclude_sat] = '1'
    params[:weekday_exclude_sun] = '1'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end

=end
  test "Advanced monthly 28th unless weekends, then previous Friday" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'monthly'
    params[:days] = 'specific'
    params[:dates_picked] = '28'
    params[:weekday_exclude_sat] = '1'
    params[:weekday_exclude_sun] = '1'
    params[:exclusion_met] = 'previous'
    params[:exclusion_met2] = 'fri'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    puts Schedule.get_form_params(schedule).to_yaml
  end
=begin
=end
  def reset_params(date='25-Mar-2019')
    return {
      type: 'simple',
      name: 'test schedule',
      start_date: date,
      timezone: 'Europe/London',
      schedule: '',
      run_every: '1',
      days: '',
      days2: '',
      dates_picked: '',
      weekday_mon: '0',
      weekday_tue: '0',
      weekday_wed: '0',
      weekday_thu: '0',
      weekday_fri: '0',
      weekday_sat: '0',
      weekday_sun: '0',
      end_date: '',
      weekday_exclude_mon: '0',
      weekday_exclude_tue: '0',
      weekday_exclude_wed: '0',
      weekday_exclude_thu: '0',
      weekday_exclude_fri: '0',
      weekday_exclude_sat: '0',
      weekday_exclude_sun: '0',
      dates_picked_exclude: '',
      exclusion_met1: '',
      exclusion_met2: ''
    }
  end

end