class AccountController < ApplicationController
  def show
    @account_name = params[:id]
    @active_account = Account.where(name: @account_name, user_id: current_user.id).take

    if @active_account
      @account_id = @active_account.id
      @account_currency = Account.get_currency(@active_account)
    else
      @account_id = 'all'
      @account_currency = User.get_currency(current_user)
    end

    params[:id] = @account_id

    @account_transactions = Account.get_transactions(params, current_user)
    @daily_totals = Account.get_daily_totals(@account_id, @account_transactions[:transactions], current_user)
    
  end

  def create
    result = Account.create_from_string(new_account_params, current_user)
    if (result === true)
      redirect_back(fallback_location: root_path)
    else
      redirect_to root_path, :alert => result
    end
  end

  def update
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  def edit
    account = Account.find(params[:id])
    account = Account.change_setting(account, params, current_user)

    redirect_back(fallback_location: root_path)
  end

  def set_default
    Account.set_default(params[:id], current_user)
    redirect_back(fallback_location: root_path)
  end

  def settings
    @account_id = params[:id]
  end

  private

  def new_account_params
    params.require(:account).permit(:account_string)
  end

end
