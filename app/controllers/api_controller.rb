class ApiController < ApplicationController
  def account_details
    @account = current_user.accounts.where(name: params[:id]).take

    if @account
      @account = @account.decorate if @account
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
  end

  def all_accounts_details
    @accounts = Account.get_accounts(current_user)
    render json: @accounts
  end

  def format_currency
    render json: Account.format_currency(params[:amount], params[:currency])
  end

  def convert_currency
    render json: CurrencyRate.convert(params[:amount], Money::Currency.new(params[:from]), Money::Currency.new(params[:to]))
  end

  def account_display_balance
    render json: Account.get_display_balance_html(params)
  end

  def get_user_currency
    render json: User.get_currency(current_user).iso_code
  end

end
