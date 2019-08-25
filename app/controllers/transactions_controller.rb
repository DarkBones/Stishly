class TransactionsController < ApplicationController
  def show
    @active_transaction = Transaction.find(params[:id])
    @account_id = @active_transaction.account_id
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
    @transactions = Transaction.update(params[:id], transaction_params, current_user)
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
      puts "#{id} #{current_user.transactions.where(id: id.to_i).length}"
      if current_user.transactions.where(id: id.to_i).length == 0
        @transaction_ids.push(id.to_i)
        next
      end

      transaction = current_user.transactions.find(id.to_i)
      unless transaction.nil?
        @transaction_ids += Transaction.delete(transaction, current_user)
      end
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
      Transaction.approve_transaction(transaction, approve_params)
    end

    redirect_back fallback_location: root_path
  end

  def update_upcoming_occurrence
    transaction = current_user.transactions.find(params[:id])

    @transaction = Transaction.update(transaction, transaction_params, current_user)
    @transaction = Transaction.find_main_transaction(transaction)
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
