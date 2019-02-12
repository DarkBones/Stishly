class TransactionController < ApplicationController
  def show
    @active_transaction = Transaction.find(params[:id])
    @account_id = @active_transaction.account_id
    @active_account = @active_transaction.account
  end

  def create_quick
    @user_input = params[:transaction][:user_input].to_s
    @account_id = params[:account_id].to_i

    # TODO: Create option for direction in the form
    @direction = -1

    @result = Transaction.create_from_string(params, current_user)

    # TODO: Error handling if @result != 200
    redirect_back(fallback_location: root_path)
  end

  def create
    Transaction.create(params, current_user)
    redirect_back(fallback_location: root_path)
  end
end
