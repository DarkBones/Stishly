class AccountController < ApplicationController
  def show
    @account_id = params[:id]

    if @account_id != 'all'
      @account_name = Account.find(@account_id).name
    else
      @account_name = 'All'
    end

    @currency_symbol = current_user.country.currency.symbol
    @cents_amount = current_user.country.currency.number_to_basic

    if @account_id != 'all'
      @transactions = Transaction.where("account_id" => params[:id], "user_id" => current_user.id).order(:created_at).reverse_order()
    else
      @transactions = Transaction.where("user_id" => current_user.id).order(:created_at).reverse_order()
    end
  end

  def create
    Account.create_from_string(params[:account][:name_balance].to_s, current_user)
    redirect_back(fallback_location: root_path)
  end

  def sort
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

end
