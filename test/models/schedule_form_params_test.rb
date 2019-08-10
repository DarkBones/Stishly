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

  test "Simple daily" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'daily'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "simple", format_error("Unexpected schedule type", "simple", form_params[:type])
    assert form_params[:schedule] == "days", format_error("Unexpected schedule period", "days", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "", format_error("Unexpected schedule days", "", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude].nil?, format_error("Unexpected schedule exclude", "nil", form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 6, format_error("Unexpected schedule hidden fields length", 6, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("advanced")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("monthly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Simple weekly" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'weekly'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "simple", format_error("Unexpected schedule type", "simple", form_params[:type])
    assert form_params[:schedule] == "weeks", format_error("Unexpected schedule period", "weeks", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "", format_error("Unexpected schedule days", "", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude].nil?, format_error("Unexpected schedule exclude", "nil", form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 6, format_error("Unexpected schedule hidden fields length", 6, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("advanced")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("monthly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Simple monthly" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'monthly'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "simple", format_error("Unexpected schedule type", "simple", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "", format_error("Unexpected schedule days", "", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == [], format_error("Unexpected schedule exclude", [], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 6, format_error("Unexpected schedule hidden fields length", 6, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("advanced")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Simple annually" do
    current_user = users(:bas)

    params = reset_params
    params[:schedule] = 'annually'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "simple", format_error("Unexpected schedule type", "simple", form_params[:type])
    assert form_params[:schedule] == "years", format_error("Unexpected schedule period", "years", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "", format_error("Unexpected schedule days", "", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude].nil?, format_error("Unexpected schedule exclude", "nil", form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 6, format_error("Unexpected schedule hidden fields length", 6, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("advanced")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("monthly")
    assert form_params[:hidden_fields].include?("weekly")
  end

  test "Advanced weekly Monday and Friday" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'weekly'
    params[:weekday_mon] = '1'
    params[:weekday_fri] = '1'

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "weeks", format_error("Unexpected schedule period", "weeks", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "", format_error("Unexpected schedule days", "", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked] == ["mon", "fri"], format_error("Unexpected schedule days picked", ["mon", "fri"], form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude].nil?, format_error("Unexpected schedule exclude", "nil", form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 5, format_error("Unexpected schedule hidden fields length", 5, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("monthly")
    assert form_params[:hidden_fields].include?("annually")
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
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "weeks", format_error("Unexpected schedule period", "weeks", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "", format_error("Unexpected schedule days", "", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked] == ["sun", "mon", "tue", "wed", "thu", "fri", "sat"], format_error("Unexpected schedule days picked", ["sun", "mon", "tue", "wed", "thu", "fri", "sat"], form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude].nil?, format_error("Unexpected schedule exclude", "nil", form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 5, format_error("Unexpected schedule hidden fields length", 5, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("monthly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Advanced monthly 28th" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = 'advanced'
    params[:schedule] = 'monthly'
    params[:days] = 'specific'
    params[:dates_picked] = '28'

    schedule = Schedule.create_from_form(params, current_user, true)

    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "specific", format_error("Unexpected schedule days", "specific", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked] == [28], format_error("Unexpected schedule days picked", [28], form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == [], format_error("Unexpected schedule exclude", [], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 5, format_error("Unexpected schedule hidden fields length", 5, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
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
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "specific", format_error("Unexpected schedule days", "specific", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked] == [28], format_error("Unexpected schedule days picked", [28], form_params[:days_picked])
    assert form_params[:advanced] == true, format_error("Unexpected schedule advanced features", true, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == ["sun", "sat"], format_error("Unexpected schedule exclude", ["sun", "sat"], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 4, format_error("Unexpected schedule hidden fields length", 4, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

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
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "specific", format_error("Unexpected schedule days", "specific", form_params[:days])
    assert form_params[:days2].nil?, format_error("Unexpected schedule days2", "nil", form_params[:days2])
    assert form_params[:days_picked] == [28], format_error("Unexpected schedule days picked", [28], form_params[:days_picked])
    assert form_params[:advanced] == true, format_error("Unexpected schedule advanced features", true, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == ["sun", "sat"], format_error("Unexpected schedule exclude", ["sun", "sat"], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2] == "fri", format_error("Unexpected schedule exclusion_met2", "fri", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 4, format_error("Unexpected schedule hidden fields length", 4, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("days2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Advanced monthly last friday" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = "advanced"
    params[:schedule] = "monthly"
    params[:days] = "last"
    params[:days2] = "fri"

    schedule = Schedule.create_from_form(params, current_user, true)

    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml

    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "last", format_error("Unexpected schedule days", "last", form_params[:days])
    assert form_params[:days2] == "fri", format_error("Unexpected schedule days2", "fri", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == [], format_error("Unexpected schedule exclude", [], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 4, format_error("Unexpected schedule hidden fields length", 4, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Advanced monthly last day" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = "advanced"
    params[:schedule] = "monthly"
    params[:days] = "last"
    params[:days2] = "day"

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml
    
    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "last", format_error("Unexpected schedule days", "last", form_params[:days])
    assert form_params[:days2] == "day", format_error("Unexpected schedule days2", "day", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == false, format_error("Unexpected schedule advanced features", false, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == [], format_error("Unexpected schedule exclude", [], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 4, format_error("Unexpected schedule hidden fields length", 4, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("advanced2")
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Advanced monthly last day except on mondays and wednesdays" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = "advanced"
    params[:schedule] = "monthly"
    params[:days] = "last"
    params[:days2] = "day"
    params[:weekday_exclude_mon] = "1"
    params[:weekday_exclude_wed] = "1"

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml
    
    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "last", format_error("Unexpected schedule days", "last", form_params[:days])
    assert form_params[:days2] == "day", format_error("Unexpected schedule days2", "day", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == true, format_error("Unexpected schedule advanced features", true, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == ["mon", "wed"], format_error("Unexpected schedule exclude", ["mon", "wed"], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 3, format_error("Unexpected schedule hidden fields length", 3, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Advanced monthly last Friday except on 1st and 28th" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = "advanced"
    params[:schedule] = "monthly"
    params[:days] = "last"
    params[:days2] = "fri"
    params[:dates_picked_exclude] = "1 28"

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml
    
    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "last", format_error("Unexpected schedule days", "last", form_params[:days])
    assert form_params[:days2] == "fri", format_error("Unexpected schedule days2", "fri", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == true, format_error("Unexpected schedule advanced features", true, form_params[:advanced])
    assert form_params[:end_date].nil?, format_error("Unexpected schedule end date", "nil", form_params[:end_date])
    assert form_params[:exclude] == [1, 28], format_error("Unexpected schedule exclude", [1, 28], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 3, format_error("Unexpected schedule hidden fields length", 3, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

  test "Advanced with end date" do
    current_user = users(:bas)

    params = reset_params
    params[:type] = "advanced"
    params[:schedule] = "monthly"
    params[:days] = "last"
    params[:days2] = "day"
    params[:end_date] = "25-Jul-2019"

    schedule = Schedule.create_from_form(params, current_user, true)
    
    form_params = Schedule.get_form_params(schedule)
    #puts form_params.to_yaml
    
    assert form_params[:type] == "advanced", format_error("Unexpected schedule type", "advanced", form_params[:type])
    assert form_params[:schedule] == "months", format_error("Unexpected schedule period", "months", form_params[:schedule])
    assert form_params[:run_every] == 1, format_error("Unexpected period num", 1, form_params[:run_every])
    assert form_params[:days] == "last", format_error("Unexpected schedule days", "last", form_params[:days])
    assert form_params[:days2] == "day", format_error("Unexpected schedule days2", "day", form_params[:days2])
    assert form_params[:days_picked].nil?, format_error("Unexpected schedule days picked", "nil", form_params[:days_picked])
    assert form_params[:advanced] == true, format_error("Unexpected schedule advanced features", true, form_params[:advanced])
    assert form_params[:end_date] == '25-Jul-2019', format_error("Unexpected schedule end date", "25-Jul-2019", form_params[:end_date])
    assert form_params[:exclude] == [], format_error("Unexpected schedule exclude", [], form_params[:exclude])
    assert form_params[:exclusion_met1] == "previous", format_error("Unexpected schedule exclusion_met1", "previous", form_params[:exclusion_met1])
    assert form_params[:exclusion_met2].nil?, format_error("Unexpected schedule exclusion_met2", "nil", form_params[:exclusion_met2])

    assert form_params[:hidden_fields].length == 3, format_error("Unexpected schedule hidden fields length", 3, form_params[:hidden_fields].length)
    assert form_params[:hidden_fields].include?("daily")
    assert form_params[:hidden_fields].include?("weekly")
    assert form_params[:hidden_fields].include?("annually")
  end

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