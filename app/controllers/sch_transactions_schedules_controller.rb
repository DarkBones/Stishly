class SchTransactionsSchedulesController < ApplicationController

  def create
    SchTransactionsSchedule.join_transactions(join_params, current_user)
  end

private

  def join_params
    params.require(:sch_transactions_schedule).permit(:schedules, :transactions)
  end
  
end
