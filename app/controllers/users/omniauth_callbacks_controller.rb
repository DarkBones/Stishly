class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      if @user.save
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
      else
        message = ""
        @user.errors.messages.each do |key, val|
          message += "#{key} #{val[0]} "
        end
        redirect_to new_user_session_path, :alert => message
      end
    end
  end

  def failure
    redirect_to root_path
  end
  
end