class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      redirect_to root_path + 'app' and return
    end

    ab_test(:landing_page, "sign_up_form", "jumbotron") do |page_type|
    	if page_type == 'sign_up_form'
    		redirect_to new_user_registration_path and return
    	end
    end

  end
end
