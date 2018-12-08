class AccountController < ApplicationController
  def show
    @account_transactions = Account.get_transactions(params, current_user)
    @account_id = params[:id]
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

  def update
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  def edit
    sett_name = params[:setting_value].keys[0].to_s
    sett_value = params[:setting_value].values[0].to_s
    account = Account.find(params[:id])
    SettingValue.save_setting(account, {name: sett_name, value: sett_value})
  end

  def settings
    @account_id = params[:id]
  end

  private

  def new_account_params
    params.require(:account).permit(:account_string)
  end

end
