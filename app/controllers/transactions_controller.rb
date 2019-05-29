class TransactionsController < ApplicationController
  def show
    @active_transaction = Transaction.find(params[:id])
    @account_id = @active_transaction.account_id
    @active_account = @active_transaction.account
  end

  def create
    @params = params[:transaction]
    all_transactions = Transaction.create(transaction_params, current_user)

    puts params.to_yaml

    transactions = []
    if @params[:active_account] == ''
      transactions = all_transactions
    else
      active_account_id = Account.get_from_name(@params[:active_account], current_user).id
      all_transactions.each do |t|
        transactions.push(t) if t.account_id == active_account_id
      end
    end


    transaction_details = Transaction.get_details(transactions, transaction_details_params, current_user)

    @transaction_amounts_all = transaction_details[:transaction_amounts_all]
    @account_ids_all = transaction_details[:account_ids_all]
    @transactions_parent = transaction_details[:transactions_parent]
    @account_names = transaction_details[:account_names]
    @date = transaction_details[:date]
    @update_day_total = transaction_details[:update_day_total]
    @total_amount = transaction_details[:total_amount].to_s
  end

  def update
    @transactions = Transaction.update(params[:id], transaction_params, current_user)
    redirect_back fallback_location: root_path
  end

private

  def transaction_details_params
    params.permit(:active_account)
  end
  
  def transaction_params
    params.require(:transaction).permit(
      :id,
      :account,
      :from_account,
      :to_account,
      :multiple,
      :timezone,
      :category_id,
      :currency,
      :date,
      :time,
      :rate_from_to,
      :rate,
      :type,
      :description,
      :amount,
      :transactions,
      :active_account,
      :account_currency,
      :to_account_currency
      )
  end

end
