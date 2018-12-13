class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :country_code, :password, :password_confirmation, :timezone)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :country_code, :password, :password_confirmation, :current_password)
  end
end