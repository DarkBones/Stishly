class AccountController < ApplicationController

  def show
    @account_id = params[:id]
    if @account_id != 'all'
      @transactions = Transaction.where("account_id" => params[:id], "user_id" => current_user.id)
    else
      @transactions = Transaction.where("user_id" => current_user.id)
    end
  end

  def create
    Account.create_from_string(params[:account][:name_balance].to_s, current_user.id, current_user.country.currency.number_to_basic)
    redirect_back(fallback_location: root_path)
  end

  def sort
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

end
