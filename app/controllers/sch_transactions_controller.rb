class SchTransactionsController < ApplicationController

  def create
    SchTransactionsSchedule.join_transactions(join_params, current_user)
  end

  def update
    @transactions = SchTransaction.update(update_params, current_user)
    redirect_back fallback_location: root_path
  end

private

  def join_params
    params.require(:sch_transaction).permit(:schedules, :transactions)
  end

  def update_params
    params.require(:sch_transaction).permit(
      :id,
      :description,
      :account,
      :from_account,
      :to_account,
      :category_id,
      :currency,
      :amount,
      :transactions,
      :multiple,
      :type
      )
  end


end
