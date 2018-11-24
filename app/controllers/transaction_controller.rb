class TransactionController < ApplicationController
  def create_quick
    @user_input = params[:transaction][:user_input].to_s
    @account_id = params[:account_id].to_i

    # TODO: Create option for direction in the form
    @direction = -1

    @result = Transaction.create_from_string(@user_input, current_user, @account_id, @direction)

    # TODO: Error handling if @result != 200
    redirect_back(fallback_location: root_path)
  end
end
