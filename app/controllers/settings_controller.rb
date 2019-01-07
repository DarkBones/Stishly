class SettingsController < ApplicationController
  def edit
    User.save_setting(current_user, { name: 'currency', value: params[:user_setting][:currency] })
    redirect_back(fallback_location: root_path)
  end
end
