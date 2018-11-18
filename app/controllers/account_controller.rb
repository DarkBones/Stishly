class AccountController < ApplicationController

  def create
    Account.create(:user_id => current_user.id, :name => "Current account")
  end

  def sort
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

end
