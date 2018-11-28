class AccountController < ApplicationController
  def show
    @account_transactions = AccountService.new(params, current_user).perform
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
