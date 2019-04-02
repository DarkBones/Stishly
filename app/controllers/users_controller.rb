class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to root_path, :notice => 'no problems'
    else
      redirect_to root_path, :alert => 'something went wrong'
    end
  end

  def settings
  end

  def edit
    User.change_setting(current_user, params)

    redirect_back(fallback_location: root_path)
  end

  private
  def secure_params
    params.require(:user).permit(:role)
  end
end
