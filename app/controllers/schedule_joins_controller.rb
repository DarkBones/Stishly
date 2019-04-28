class ScheduleJoinsController < ApplicationController

  def create
    ScheduleJoin.join_transactions(join_params, current_user)
  end

private
  
  def join_params
    params.require(:schedule_join).permit(:schedules, :transactions)
  end

end
