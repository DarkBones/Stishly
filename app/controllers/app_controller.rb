class AppController < ApplicationController
  def index
    #Account.create(:balance => 100, :currency_id => 56, :user_id => 20, :name => "CURRENT", :description => "Hello")
    @accounts = Account.where("user_id" => current_user.id)
    @currency_symbol = current_user.country.currency.symbol
    @cents_amount = current_user.country.currency.number_to_basic
    @total_balance = Account.where("user_id" => current_user.id ).sum(:balance)
  end

  def create_account
    reg = "^[a-zA-Z0-9\s]+[0-9]*[\.]*[0-9\.\s]+$"
    @name_balance = params[:account][:name_balance].strip

    if /#{reg}/.match(@name_balance)
      @cents_amount = current_user.country.currency.number_to_basic
      @name_balance = @name_balance.split

      @name = @name_balance[0..-2].join(' ')

      @cents_amount > 0 ? @balance = (@name_balance[-1].to_f * @cents_amount).to_i : @balance = @name_balance[-1].to_i

      Account.create(:user_id => current_user.id, :name => @name, :balance => @balance)
      redirect_to root_path
    else
      Account.create(:user_id => current_user.id, :name => @name_balance, :balance => 0)
      redirect_to root_path
    end

    @cents_amount = current_user.country.currency.number_to_basic
  end

  def transtring(s)
    return "transformed " + s.to_s
  end
end
