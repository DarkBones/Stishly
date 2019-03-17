class SchedulesController < ApplicationController
  def index
  end

  def create
    schedule = Schedule.create_from_form(params, current_user)
    schedule.save
  end
end
