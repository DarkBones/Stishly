class AccountsController < ApplicationController
  def show
    @active_account = current_user.accounts.where(name: params[:id]).take.decorate
    @account_currency = Account.get_currency(@active_account)

    @account_transactions = Account.get_transactions(@active_account, params[:page], current_user).decorate
    @daily_totals = Account.get_daily_totals(@active_account.id, @account_transactions, current_user)
  end

  def index
    @active_account = Account.create_summary_account(current_user).decorate
    @account_currency = User.get_currency(current_user)

    @account_transactions = Account.get_transactions(@active_account, params[:page], current_user).decorate
    @daily_totals = Account.get_daily_totals(@active_account.id, @account_transactions, current_user)

    render 'show'
  end

  def details
    @account = current_user.accounts.where(name: params[:id]).take.decorate
    render json: @account
  end

  def create
    @account = Account.create_new(params[:account], current_user)

    respond_to do |format|
      if @account.is_a? String
        format.html { render :new }
        format.json { render json: @account, status: :unprocessable_entity }
        format.js
      else
        @account = @account.decorate
        format.html { redirect_to @account }
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
    @active_account = current_user.accounts.where(name: params[:id]).take.decorate
  end

  private

  def new_account_params
    params.require(:account).permit(:account_string)
  end

end
