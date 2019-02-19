class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_user

  helper_method :user_accounts, :user_accounts_array, :user_categories_array

  def get_accounts_currencies
    @accounts_currencies = Account.get_accounts_with_currencies(current_user)
  end

  def set_current_user
    User.set_current_user(current_user)
  end

  def user_accounts
    @user_accounts = Account.get_accounts(current_user)
    OpenStruct.new(
      accounts: @user_accounts
      )
  end

  def user_accounts_array
    accounts = []

    Account.get_accounts(current_user).each do |a|
      accounts.push(a.name) if a.id > 0
    end

    return accounts
  end

  def user_categories_array
    categories = []

    current_user.categories.each do |c|
      categories.push("<b>" + c.symbol + "</b>".html_safe)
    end

    return categories
  end

  private

  def after_sign_in_path_for(resource_or_scope)
    User.update(current_user.id, :timezone => params[:user][:timezone])
    root_path
  end
end
