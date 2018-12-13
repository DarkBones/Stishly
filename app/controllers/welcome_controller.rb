class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    if user_signed_in?
      redirect_to root_path + 'app'
    end
  end
end
