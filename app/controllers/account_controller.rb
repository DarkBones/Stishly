class AccountController < ApplicationController

  def create
    Account.create(:user_id => current_user.id, :name => "Current account")
  end

end
