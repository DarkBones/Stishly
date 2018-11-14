class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to root_path + 'app'
    end
  end
end
