class TransactionController < ApplicationController
  def create_quick
    @user_input = params[:transaction][:user_input].to_s
    @account_id = params[:account_id].to_i

    @result = Transaction.create_from_string(@user_input, current_user, @account_id, -1)

  end
end
