class SchedulesController < ApplicationController
  def index
    @schedules = current_user.schedules.where(:is_active => 1).order(:next_occurrence).decorate
    @inactive_schedules = current_user.schedules.where(:is_active => 0).order(:next_occurrence).decorate
  end

  def create
    @schedule = Schedule.create_from_form(schedule_params, current_user)
    @schedule.save if @schedule.is_a?(ActiveRecord::Base)
  end

  def run_schedules
    require "time"
    schedules_to_run = Schedule.where("next_occurrence_utc <= ? AND is_active = ?", Time.now, true)

    schedules_to_run.each do |s|
      puts s.name
    end

    render plain: schedules_to_run.length
  end

private
  
  def schedule_params
    params.require(:schedule).permit(
      :name,
      :type,
      :start_date,
      :timezone,
      :schedule,
      :run_every,
      :days,
      :days2,
      :dates_picked,
      :weekday_mon,
      :weekday_tue,
      :weekday_wed,
      :weekday_thu,
      :weekday_fri,
      :weekday_sat,
      :weekday_sun,
      :end_date,
      :weekday_exclude_mon,
      :weekday_exclude_tue,
      :weekday_exclude_wed,
      :weekday_exclude_thu,
      :weekday_exclude_fri,
      :weekday_exclude_sat,
      :weekday_exclude_sun,
      :dates_picked_exclude,
      :exclusion_met1,
      :exclusion_met2,
      :occurrence_count
      )
  end

end
