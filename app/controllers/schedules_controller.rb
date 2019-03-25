class SchedulesController < ApplicationController
  def index
    @schedules = current_user.schedules.where(:is_active => 1)
    @inactive_schedules = current_user.schedules.where(:is_active => 0)
  end

  def create
    @schedule = Schedule.create_from_form(params, current_user)
    @schedule.save if @schedule.is_a?(ActiveRecord::Base)
  end
end
