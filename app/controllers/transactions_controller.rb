class TransactionsController < ApplicationController
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
    @params = params[:transaction]
    transactions = Transaction.create(params, current_user)

    transaction_details = Transaction.get_details(transactions, params, current_user)

    @transaction_amounts_all = transaction_details[:transaction_amounts_all]
    @account_ids_all = transaction_details[:account_ids_all]
    @transactions_parent = transaction_details[:transactions_parent]
    @account_names = transaction_details[:account_names]
    @date = transaction_details[:date]
    @update_day_total = transaction_details[:update_day_total]
    @total_amount = transaction_details[:total_amount].to_s
  end
end
