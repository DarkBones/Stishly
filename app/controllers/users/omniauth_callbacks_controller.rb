class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
	def facebook
    handle_request("Facebook", request)
  end

  def google_oauth2
    handle_request("Google", request)
  end

  def failure
    redirect_to root_path
  end

private

  def handle_request(provider, request)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
    else
      session["devise." + provider.downcase + "_data"] = request.env["omniauth"]
      if @user.save
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
      else
        message = ""
        @user.errors.messages.each do |key, val|
          message += "#{key} #{val[0]} "
        end
        redirect_to new_user_session_path, :alert => message
      end
    end

  end
  
end