class TransactionsController < ApplicationController
  def show
    @active_transaction = Transaction.find(params[:id])
    @account_id = @active_transaction.account_id
    @active_account = @active_transaction.account
  end

  def create
    @params = params[:transaction]
    all_transactions = Transaction.create(transaction_params, current_user)

    active_account = nil

    transactions = []
    if @params[:active_account] == ''
      transactions = all_transactions
    else
      active_account = Account.get_from_name(@params[:active_account], current_user)
      all_transactions.each do |t|
        transactions.push(t) if t.account_id == active_account.id
      end
    end


    transaction_details = Transaction.get_details(transactions, active_account, current_user)

    @transaction_amounts_all = transaction_details[:transaction_amounts_all]
    @account_ids_all = transaction_details[:account_ids_all]
    @transactions_parent = transaction_details[:transactions_parent]
    @account_names = transaction_details[:account_names]
    @date = transaction_details[:date]
    @update_day_total = transaction_details[:update_day_total]
    @total_amount = transaction_details[:total_amount].to_s

    redirect_back fallback_location: root_path if transactions[0].is_scheduled
  end

  def update
    @transactions = Transaction.update(params[:id], transaction_params, current_user)
    redirect_back fallback_location: root_path
  end

  def queued
    @transactions = current_user.transactions.where("is_queued = true").decorate
  end

  def discard
    transaction = current_user.transactions.find(params[:id])
    transaction.destroy unless transaction.nil?
    redirect_back fallback_location: root_path
  end

  def approve
    transaction = current_user.transactions.find(params[:id])

    unless transaction.nil?
      Transaction.approve_transaction(transaction)
    end

    redirect_back fallback_location: root_path
  end

private
  
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
      :to_account_currency,
      :schedule_id,
      :schedule_type
      )
  end

end
