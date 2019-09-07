class ApiGuiController < BaseApiBrowserController

  def render_account_title_balance
    unless params[:account].nil?
      account = Account.get_from_name(params[:account], current_user).decorate
      html = Money.new(account.balance, account.currency).format
      float = account.balance_float
    else
      html = Money.new(current_user.accounts.sum(:balance), current_user.currency).format
      float = 0
    end

    render json: {
      html: html,
      float: float
    }
  end

	def account_display_balance
		render json: "bad request", status: :bad_request and return unless params[:amount] && params[:from] && params[:to] && params[:add]

		begin
			from_currency = Money::Currency.new(params[:from])
			to_currency = Money::Currency.new(params[:to])
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end

		render json: Account.get_display_balance_html(params)
	end

  def create_transaction
    transaction = current_user.transactions.find(params[:transaction_id]).decorate
    transfer_transaction = transaction.transfer_transaction.decorate unless transaction.transfer_transaction.nil?

    unless params[:account_name].nil?
      account = Account.get_from_name(params[:account_name], current_user).decorate
      currency = account.currency
      balance_html = Money.new(account.balance, account.currency).format
      balance_float = account.balance_float
    else
      balance_html = Money.new(current_user.accounts.sum(:balance), current_user.currency).format
      balance_float = 0
    end

    date_formatted = User.format_date(transaction.local_datetime.to_date, false, false)
    d = transaction.local_datetime.to_date.to_s
    currency ||= current_user.currency
 
    day_total = Account.day_total(account, current_user, transaction.local_datetime.to_date)

    transactions = []

    if params[:account_name].nil? || params[:account_name] == transaction.account.name
      transactions.push(render_to_string partial: 'accounts/transaction', :locals => { :active_account => account, :transaction => transaction })
    end

    unless transfer_transaction.nil?
      if params[:account_name].nil? || params[:account_name] == transfer_transaction.account.name
        transactions.push(render_to_string partial: 'accounts/transaction', :locals => { :active_account => account, :transaction => transfer_transaction }) unless transaction.transfer_transaction.nil?
      end
    end

    render json: {
      title_balance_html: balance_html,
      title_balance_float: balance_float,
      date: transaction.local_datetime.to_date.to_s,
      date_num: (transaction.local_datetime.to_date.to_s.gsub! '-', ''),
      time: transaction.local_datetime.strftime("%H%M%S"),
      date_div: (render_to_string partial: 'accounts/transactions_date', :locals => { :d => d, :account_currency => currency, :day_total => day_total, :d_formatted => date_formatted }),
      transactions: transactions
    }
  end

	def new_account_form
		render partial: "accounts/new_account_form"
	end

	def new_transaction_form
		render partial: "transactions/new_transactions_form"
	end

	def new_schedule_form
		render partial: "schedules/new_schedule_form"
	end

	def render_notifications
		render partial: "layouts/notifications"
	end

	def render_transaction
    active_account = Account.get_from_name(params[:account], current_user)
    transaction = current_user.transactions.find(params[:transaction]).decorate

    render partial: 'accounts/transaction', :locals => { :active_account => active_account, :transaction => transaction }
  end

  def render_schedule_transactions
    schedule = current_user.schedules.friendly.find(params[:schedule])
    transactions = schedule.user_transactions.where("parent_id is null AND (transfer_transaction_id is null OR (transfer_transaction_id is not null AND direction = -1))").order(:description).decorate
    
    render partial: "schedules/transactionlist", :locals => {:transactions => transactions, :schedule_id => params[:schedule]}
  end

  #def render_transaction_date
  #	date_formatted = User.format_date(params[:date].to_date, false, false)
  #  render partial: 'accounts/transactions_date', :locals => { :d => params[:date], :account_currency => params[:account_currency], :day_total => params[:day_total], :d_formatted => date_formatted }
  #end

  def render_transaction_date
    account = Account.get_from_name(params[:account], current_user) unless params[:account].nil?
    date = params[:date].to_date
    date_formatted = User.format_date(params[:date].to_date, false, false)
    day_total = Account.day_total(account, current_user, date)

    if account.nil?
      currency = current_user.currency
    else
      currency = account.currency
    end

    render partial: 'accounts/transactions_date', :locals => { :d => params[:date], :account_currency => currency, :day_total => day_total, :d_formatted => date_formatted }
  end

  def edit_schedule_form
  	schedule = current_user.schedules.find(params[:id])

  	render partial: "schedules/edit_schedule_form", :locals => {:schedule => schedule}
  end

  def render_schedule_pauseform
  	schedule = current_user.schedules.friendly.find(params[:id])

  	render partial: "schedules/schedule_pause_form", :locals => {:schedule => schedule}
  end

  def edit_upcoming_transaction_occurrence_form
  	transaction = current_user.transactions.find(params[:id]).decorate
  	render partial: "transactions/edit_upcoming_transaction_occurrence", :locals => {:transaction => transaction, :schedule_id => params[:schedule_id], :schedule_period_id => params[:schedule_period_id], :scheduled_transaction_id => params[:scheduled_transaction_id]}
  end

  def edit_transaction
    transaction = current_user.transactions.find(params[:id]).decorate
    render partial: "transactions/edit_transaction", :locals => {:transaction => transaction}
  end

  def edit_upcoming_transaction_series_form
  	transaction = current_user.transactions.find(params[:id]).decorate
  	render partial: "transactions/edit_upcoming_transaction_series", :locals => {:transaction => transaction}
  end

  def render_schedules_table
    if params[:type] == "active"
      render partial: 'schedules/schedules_table', :locals => {:active => true}
    elsif params[:type] == "paused"
      render partial: 'schedules/schedules_table', :locals => {:active => true, :paused => true}
    elsif params[:type] == "inactive"
      render partial: 'schedules/schedules_table', :locals => {:active => false}
    end
  end

  def render_schedule_table_row
    schedule = current_user.schedules.friendly.find(params[:id]).decorate
    render partial: "schedules/schedule", :locals => {:schedule => schedule}
  end

  def swap_schedules_table
    schedule = current_user.schedules.friendly.find(params[:schedule]).decorate
    render partial: "schedules/swap_table", :locals => {:schedule => schedule, :from => params[:from]}
  end

  def render_upcoming_transaction_dropdown
    transaction = current_user.transactions.find(params[:id]).decorate
    schedule = transaction.schedule

    if schedule.nil?
      schedule_id = 0
      period_id = 0
    else
      schedule_id = schedule.hash_id
      period_id = transaction.schedule_period_id
    end

    transaction_id = schedule_id.to_s + transaction.id.to_s + period_id.to_s

    scheduled_transaction_id = transaction.id
    scheduled_transaction_id = transaction.scheduled_transaction_id unless transaction.scheduled_transaction_id.nil?

    render partial: "transactions/upcoming_transaction_dropdown", :locals => {
      :transaction_id => transaction_id, 
      :transaction => transaction, 
      :scheduled_transaction_id => scheduled_transaction_id, 
      :schedule => schedule}

  end

  def render_left_menu
    render partial: 'layouts/left_menu', :locals => {active_account: 0}
  end

  def render_scheduled_transaction
    transaction = current_user.transactions.find(params[:id]).decorate
    render partial: 'schedules/transaction', :locals => {:transaction => transaction}
  end

private
	
	def display_balance_params
		params.permit(:account, :amount, :from, :to, :add)
	end

end
