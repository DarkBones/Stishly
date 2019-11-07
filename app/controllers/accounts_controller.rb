class AccountsController < ApplicationController

  add_breadcrumb "Accounts", :accounts_path

  def destroy
    Account.delete(current_user.accounts.friendly.find(params[:id]))
    redirect_to "/accounts", notice: "Account deleted"
  end

  def overview
    unless current_user.subscription == 'free'
      @active_account = Account.get_from_name(params[:id], current_user) or not_found

      add_breadcrumb @active_account.name, account_path(@active_account.slug)
      add_breadcrumb "Insights", account_path(@active_account.slug) + "/overview"

      @active_account = @active_account.decorate

      @history_data = ChartDatum.account_history(@active_account)
      @category_data = ChartDatum.account_categories(@active_account)
      @category_data_income = ChartDatum.account_categories(@active_account, type: "income")
    else
      redirect_to plans_path
    end
  end

  def overview_all
    unless current_user.subscription == 'free'
      @active_account = Account.create_summary_account(current_user, true).decorate

      add_breadcrumb "Insights", "accounts_overview"

      @history_data = ChartDatum.user_history(current_user)
      @category_data = ChartDatum.user_categories(current_user)
      @category_data_income = ChartDatum.user_categories(current_user, type: "income")

      render "overview"
    else
      redirect_to plans_path
    end
  end

  def update
    account = current_user.accounts.where(hash_id: params[:id]).take

    if Account.update_account(account, update_params)
      @active_account = current_user.accounts.friendly.find(params[:id])
      redirect_to "/accounts", notice: "Account saved" if params[:account].include?("name")
    else
      redirect_back(fallback_location: root_path, notice: "Failed to update account")
    end
  end

  def show
    puts params.to_yaml
    @active_account = Account.get_from_name(params[:id], current_user) or not_found

    not_found if @active_account.nil?

    add_breadcrumb @active_account.name, account_path(@active_account.slug)

    @active_account = @active_account.decorate

    #@active_account = current_user.accounts.where(name: params[:id]).take.decorate
    #@active_account = current_user.accounts.friendly.find(params[:id]).decorate

    unless params.keys.include? "filterrific"
      params[:filterrific] = {
        sorted_by: 'created_at_desc',
        is_queued: 'false',
        include_children: 1,
        is_balancer: 'false'
      }
    end
    params[:filterrific][:account] = params[:id]

    @filterrific = initialize_filterrific(
      current_user.transactions,
      params[:filterrific]
    ) or return

    @transactions = @filterrific.find.page(params[:page]).includes(:category, :children).decorate

    @daily_totals = Account.get_daily_totals(@active_account.id, @transactions, current_user)
    @account_currency = Account.get_currency(@active_account)
    
    filter_keys = []
    filter_keys = params[:filterrific].keys.dup if params[:filterrific]
    filter_keys.delete("account")
    filter_keys.delete("sorted_by")
    filter_keys.delete("is_queued")
    filter_keys.delete("include_children")
    filter_keys.delete("is_balancer")
    
    @filtered = filter_keys.length > 0

  end

  def index
    @active_account = Account.create_summary_account(current_user, true).decorate

    unless params.keys.include? "filterrific"
      params[:filterrific] = {
        sorted_by: 'created_at_desc',
        is_queued: 'false',
        include_children: 1,
        is_balancer: 'false'
      }
    end
    
    @filterrific = initialize_filterrific(
      current_user.transactions,
      params[:filterrific]
    ) or return
    @transactions = @filterrific.find.page(params[:page]).includes(:category, :children).decorate

    @daily_totals = Account.get_daily_totals(@active_account.id, @transactions, current_user)
    @account_currency = Account.get_currency(@active_account)

    filter_keys = []
    filter_keys = params[:filterrific].keys.dup if params[:filterrific]
    filter_keys.delete("account")
    filter_keys.delete("sorted_by")
    filter_keys.delete("is_queued")
    filter_keys.delete("include_children")
    filter_keys.delete("is_balancer")

    
    @filtered = filter_keys.length > 0

    render 'show'
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
      Account.where(hash_id: id).update_all(position: index + 1)
    end

    head :ok
  end

  def edit
    account = current_user.accounts.friendly.find(params[:id])
    Account.change_setting(account, account_settings_params)

    redirect_back(fallback_location: root_path)
  end

  def set_default
    Account.set_default(params[:id], current_user)
    redirect_back(fallback_location: root_path)
  end

  def settings
    @active_account = Account.get_from_name(params[:id], current_user) or not_found
    @active_account = @active_account.decorate

    add_breadcrumb @active_account.name, account_path(@active_account.slug)
    add_breadcrumb "Settings", account_path(@active_account.slug) + "/settings"
  end

  private

  def new_account_params
    params.require(:account).permit(:name, :balance, :currency, :description, :account_type)
  end

  def account_settings_params
    params.require(:account).permit(:setting)
  end

  def update_params
    params.require(:account).permit(:name, :balance, :description, :account_type)
  end

end
