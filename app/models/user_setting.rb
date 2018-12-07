class UserSetting < ApplicationRecord
  belongs_to :user
  belongs_to :setting

  def self.get_setting(current_user, setting)
    sett = current_user.settings.find_by(description: setting)
    if sett
      return sett.user_settings.first
    else
      return false
    end
  end
end
