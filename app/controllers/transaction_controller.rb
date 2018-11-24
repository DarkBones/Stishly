class TransactionController < ApplicationController
  def create_quick
    @user_input = params[:transaction][:user_input].to_s
  end
end
