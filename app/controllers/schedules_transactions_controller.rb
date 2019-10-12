class SchedulesTransactionsController < ApplicationController
  
  def create
    Schedule.invalidate_scheduled_transactions_cache(current_user)
    @budget = DailyBudget.recalculate(current_user)
    
    SchedulesTransaction.join_transactions(join_params, current_user)
    @schedule = current_user.schedules.find(join_params[:schedules]).name
    @number = join_params[:transactions].split(" ").length
    @transaction = "transaction"
    if @number != 1
      @transaction += "s"
    end
  end

private

  def join_params
    params.require(:schedules_transaction).permit(:schedules, :transactions)
  end

end
