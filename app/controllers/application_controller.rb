class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def after_sign_in_path_for(resource_or_scope)
    User.update(current_user.id, :timezone => params[:user][:timezone])
  end
end
