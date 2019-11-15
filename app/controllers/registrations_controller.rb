class RegistrationsController < Devise::RegistrationsController

  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    render_resource(resource)
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :country_code, :currency, :password, :password_confirmation, :timezone)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :country_code, :password, :password_confirmation, :current_password)
  end
end