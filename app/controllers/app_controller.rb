class AppController < ApplicationController
  def index
    #Account.create(:balance => 100, :currency_id => 56, :user_id => 20, :name => "CURRENT", :description => "Hello")
    @accounts = Account.where("user_id" => current_user.id)
    #@accounts = Account.all
  end

  def create
    Account.create(:user_id => current_user.id, :name => "Current account")
  end
end
