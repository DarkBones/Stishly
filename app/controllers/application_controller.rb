class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :user_accounts

  def user_accounts
    @user_accounts = Account.get_accounts(current_user)
    OpenStruct.new(
      accounts: @user_accounts[:accounts], 
      total_balance: @user_accounts[:total_balance]
      )
  end

  private

  def after_sign_in_path_for(resource_or_scope)
    User.update(current_user.id, :timezone => params[:user][:timezone])
  end
end
