class AccountController < ApplicationController
  def show
    @account_transactions = Account.get_user_accounts(params, current_user)
  end

  def create
    #Account.create_from_string(params[:account][:name_balance].to_s, current_user)
    result = Account.create_from_string(new_account_params, current_user)
    if (result === true)
      redirect_back(fallback_location: root_path)
    else
      redirect_to root_path, :alert => result
    end
  end

  def sort
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  private

  def new_account_params
    params.require(:account).permit(:account_string)
  end

end
