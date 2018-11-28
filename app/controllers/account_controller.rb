class AccountController < ApplicationController
  def show
    @account_transactions = AccountService.new(params, current_user).perform
    puts @account_transactions
    puts '///////////////////////////////////.......................'

    @account_id = params[:id]

    @currency_symbol = current_user.country.currency.symbol
    @cents_amount = current_user.country.currency.number_to_basic
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
