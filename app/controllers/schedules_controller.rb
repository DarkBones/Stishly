class SchedulesController < ApplicationController
  def index
    @schedules = current_user.schedules.where(:is_active => 1).order(:next_occurrence).decorate
    @inactive_schedules = current_user.schedules.where(:is_active => 0).order(:next_occurrence).decorate
  end

  def create
    @schedule = Schedule.create_from_form(params, current_user)
    @schedule.save if @schedule.is_a?(ActiveRecord::Base)
  end
end
