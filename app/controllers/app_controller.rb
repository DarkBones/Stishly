class AppController < ApplicationController
  def index
    @account_id = 'na'
    @account = Account.new
  end
end
