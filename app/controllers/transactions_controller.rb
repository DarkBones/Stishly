class TransactionsController < ApplicationController

  def show
    @active_transaction = current_user.transactions.friendly.find(params[:id])
    @account_id = @active_transaction.account.hash_id
    @active_account = @active_transaction.account
  end

  def upcoming_transactions
    
    schedule = current_user.schedules.where(type_of: "main", pause_until: nil).take
    @date = schedule.next_occurrence_utc if schedule
    @date ||= Time.now.utc + 7.days

    @transactions = Schedule.get_all_transactions_until_date(current_user, @date)

    #@transactions.sort_by &:local_datetime
    @schedule = schedule
  end

  def create
    @transaction = Transaction.create(transaction_params, current_user)
  end
  
  def update
    @transaction = Transaction.update(params[:id], transaction_params, current_user)
  end

  def create_scheduled
    @transaction = Transaction.create(transaction_params, current_user, scheduled: true)
    @transaction = Transaction.find_main_transaction(@transaction)
  end

  def delete
    @transaction = current_user.transactions.find(params[:id])
    @transaction_ids = Transaction.delete(@transaction, current_user)
  end

  def mass_delete
    @transaction_ids = []
    params[:ids].split(",").each do |id|
      transaction = current_user.transactions.friendly.find(id)

      if transaction.nil?
        @transaction_ids.push(id)
        next
      end

      @transaction_ids += Transaction.delete(transaction, current_user)

    end

    render "delete"
  end

  def update_series
    @transaction = Transaction.update(params[:id], transaction_params, current_user)
    @transaction = Transaction.find_main_transaction(@transaction)
    #redirect_back fallback_location: root_path
  end

  def update_scheduled
    @transaction = Transaction.update(params[:id], transaction_params, current_user, scheduled: true)
    @transaction = Transaction.find_main_transaction(@transaction)
  end


  def queued
    @transactions = []

    transactions = current_user.transactions.where("is_queued = true AND parent_id IS NULL").decorate
    transaction_ids = []

    transactions.each do |t|
      transaction = Transaction.find_main_transaction(t)
      
      unless transaction_ids.include? transaction.id
        transaction_ids.push(transaction.id)
        @transactions.push(transaction)
      end
    end
  end

  def discard
    transaction = current_user.transactions.friendly.find(params[:id])
    transaction.destroy unless transaction.nil?
    redirect_back fallback_location: root_path
  end

  def approve
    transaction = current_user.transactions.friendly.find(params[:id])

    unless transaction.nil?
      if params[:commit] == "Approve"
        Transaction.approve_transaction(transaction, approve_params)
      else
        Transaction.destroy(transaction)
      end
    end

    redirect_back fallback_location: root_path
  end

  def update_upcoming_occurrence
    @transaction = Transaction.update_upcoming_occurrence(transaction_params, current_user)
    @transaction = Transaction.find_main_transaction(@transaction)

    redirect_back fallback_location: root_path
  end

private

  def approve_params
    params.require(:transaction).permit(:amount, :account_currency_amount, :user_currency_amount, :description)
  end
  
  def transaction_params
    params.require(:transaction).permit(
      :id,
      :scheduled_transaction_id,
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
      :schedule_type,
      :schedule_period_id
      )
  end

end
