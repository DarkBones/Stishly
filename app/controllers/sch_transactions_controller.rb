class SchTransactionsController < ApplicationController

  def create
    SchTransactionsSchedule.join_transactions(join_params, current_user)
  end

private

  def join_params
    params.require(:sch_transaction).permit(:schedules, :transactions)
  end

end
