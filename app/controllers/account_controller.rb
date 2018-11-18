class AccountController < ApplicationController

  def create
    reg = "^[a-zA-Z0-9\s]+[0-9]*[\.,]*[0-9\.\s]+$"
    @name_balance = params[:account][:name_balance].strip

    if /#{reg}/.match(@name_balance)
      @cents_amount = current_user.country.currency.number_to_basic
      @name_balance = @name_balance.split

      @name = @name_balance[0..-2].join(' ')

      @cents_amount > 0 ? @balance = (@name_balance[-1].sub(",", ".").to_f * @cents_amount).to_i : @balance = @name_balance[-1].to_i

      Account.create(:user_id => current_user.id, :name => @name, :balance => @balance)
      redirect_to root_path
    elsif @name_balance.length > 0
      Account.create(:user_id => current_user.id, :name => @name_balance, :balance => 0)
      redirect_to root_path
    else
      redirect_to root_path, :alert => 'Unexpected input'
    end

    @cents_amount = current_user.country.currency.number_to_basic
  end

  def sort
    params[:account].each_with_index do |id, index|
      Account.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

end
