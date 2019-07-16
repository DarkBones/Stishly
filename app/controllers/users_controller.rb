class UsersController < ApplicationController
  #layout :primary_background, :only => :welcome

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

  def welcome
    @layout_bg = "bg-primary"
    @hide_sidebar = true
  end

  def edit
    User.change_setting(current_user, params)

    redirect_back(fallback_location: root_path)
  end

  def submit_setup
    #puts params.to_yaml
    User.setup_user(current_user, params)
    current_user.finished_setup = 1
    current_user.save!
    redirect_to root_path, :notice => "You're all set up now"
  end

  private
  def secure_params
    params.require(:user).permit(:role)
  end

  def primary_background
    'application_primary_color'
  end

end
