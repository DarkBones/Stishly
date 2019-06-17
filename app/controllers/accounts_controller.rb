class AccountsController < ApplicationController

  def show
    @active_account = current_user.accounts.where(name: params[:id]).take.decorate

    unless params.keys.include? "filterrific"
      params[:filterrific] = { sorted_by: 'created_at_desc' }
    end
    params[:filterrific][:account] = params[:id]

    @filterrific = initialize_filterrific(
      current_user.transactions,
      params[:filterrific]
    ) or return

    @transactions = @filterrific.find.page(params[:page]).includes(:category, :children).decorate
    puts @transactions.length

    @daily_totals = Account.get_daily_totals(@active_account.id, @transactions, current_user)
    @account_currency = Account.get_currency(@active_account)
    
    filter_keys = []
    filter_keys = params[:filterrific].keys.dup if params[:filterrific]
    filter_keys.delete("account")
    filter_keys.delete("sorted_by")
    
    @filtered = filter_keys.length > 0

  end

  def index
    @active_account = Account.create_summary_account(current_user, true)

    @filterrific = initialize_filterrific(
      current_user.transactions,
      params[:filterrific]
    ) or return
    @transactions = @filterrific.find.page(params[:page]).includes(:category, :children).decorate
    puts @transactions.length

    @daily_totals = Account.get_daily_totals(@active_account.id, @transactions, current_user)
    @account_currency = Account.get_currency(@active_account)

    @filtered = params[:filterrific].nil? ? false : true

    filter_keys = []
    filter_keys = params[:filterrific].keys.dup if params[:filterrific]
    filter_keys.delete("account")
    filter_keys.delete("sorted_by")
    
    @filtered = filter_keys.length > 0

    render 'show'
  end

  def details
    @account = current_user.accounts.where(name: params[:id]).take.decorate
    render json: {
      id: @account.id,
      balance: @account.balance,
      balance_float: @account.balance_float,
      created_at: @account.created_at,
      updated_at: @account.updated_at,
      name: @account.name,
      description: @account.description,
      currency: @account.currency
    }
  end

  def format_currency
    render json: Account.format_currency(params[:amount], params[:currency])
  end

  def convert_currency
    render json: CurrencyRate.convert(params[:amount], Money::Currency.new(params[:from]), Money::Currency.new(params[:to]))
  end

  def all_details
    @accounts = Account.get_accounts(current_user)
    render json: @accounts
  end

  def create
    @account = Account.create_new(new_account_params, current_user)

    respond_to do |format|
      if @account.is_a? String
        format.html { render action: "new" }
        format.json { render json: @account, status: :unprocessable_entity }
        format.js
      else
        @account = @account.decorate
        format.json { render :show, status: :created, location: @account }
        format.js {}
      end
    end
  end

  def sort
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  def edit
    account = current_user.accounts.find(params[:id])
    Account.change_setting(account, account_settings_params)

    redirect_back(fallback_location: root_path)
  end

  def set_default
    Account.set_default(params[:id], current_user)
    redirect_back(fallback_location: root_path)
  end

  def settings
    @account_id = params[:id]
    @active_account = current_user.accounts.where(name: params[:id]).take.decorate
  end

  private

  def new_account_params
    params.require(:account).permit(:name, :balance, :currency, :description)
  end

  def account_settings_params
    params.require(:account).permit(:setting)
  end

end
