class SchedulesController < ApplicationController
  def index
    @schedules = current_user.schedules.where(:is_active => 1, :pause_until_utc => nil).order(:next_occurrence).decorate
    @paused_schedules = current_user.schedules.where("is_active = 1 AND pause_until_utc IS NOT NULL").order(:pause_until_utc).decorate
    @inactive_schedules = current_user.schedules.where(:is_active => 0).order(:next_occurrence).decorate
  end

  def create
    @schedule = Schedule.create_from_form(schedule_params, current_user)
    @schedule.save if @schedule.is_a?(ActiveRecord::Base)
    redirect_back(fallback_location: root_path)
  end

  def run_schedules(datetime=nil, schedules=nil)
    transactions = Schedule.run_schedules(date, schedules)
    return transactions
  end

  def pause
    schedule = current_user.schedules.find(params[:id])
    Schedule.pause(pause_params, schedule, current_user)
    redirect_back(fallback_location: root_path)
  end

  def edit
    @schedule = current_user.schedules.find(params[:id])
    update_params = Schedule.edit(schedule_params, @schedule)
    @schedule.update(update_params)
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

  def pause_params
    params.require(:schedule).permit(:id, :pause_until)
  end

end
