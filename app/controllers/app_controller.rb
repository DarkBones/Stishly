class AppController < ApplicationController
  def index
    #Account.create(:balance => 100, :currency_id => 56, :user_id => 20, :name => "CURRENT", :description => "Hello")
    @accounts = Account.where("user_id" => current_user.id)
    @currency_symbol = current_user.country.currency.symbol
    @cents_amount = current_user.country.currency.number_to_basic
    @total_balance = Account.where("user_id" => current_user.id ).sum(:balance)
  end

  def create_account
    Account.create(:user_id => current_user.id, :name => "Current account")
    redirect_to root_path
  end

  def transtring(s)
    return "transformed " + s.to_s
  end
end
