class TransactionController < ApplicationController
  def create
    @user_input = params[:transaction][:user_input].to_s
  end
end
