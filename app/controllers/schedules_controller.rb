class SchedulesController < ApplicationController
  def index
  end

  def create
    @schedule = Schedule.create_from_form(params, current_user)
    @schedule.save if @schedule.is_a?(ActiveRecord::Base)
  end
end
