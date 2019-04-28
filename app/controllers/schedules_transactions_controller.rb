class SchedulesTransactionsController < ApplicationController
  
  def create
    SchedulesTransaction.join_transactions(join_params, current_user)
  end

private

  def join_params
    params.require(:schedules_transaction).permit(:schedules, :transactions)
  end

end
