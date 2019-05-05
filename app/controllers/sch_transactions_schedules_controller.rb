class SchTransactionsSchedulesController < ApplicationController

  def create
    SchTransactionsSchedule.join_transactions(join_params, current_user)
    @schedule = current_user.schedules.find(join_params[:schedules]).name
    @number = join_params[:transactions].split(" ").length
    @transaction = "transaction"
    if @number != 1
      @transaction += "s"
    end
  end

private

  def join_params
    params.require(:sch_transactions_schedule).permit(:schedules, :transactions)
  end
  
end
