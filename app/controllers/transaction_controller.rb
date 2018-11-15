class TransactionController < ApplicationController
  def index
    @accounts = Account.where("user_id = " + current_user.id)
  end
end
