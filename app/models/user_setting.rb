class UserSetting < ApplicationRecord
  belongs_to :entity, :polymorphic => true
  belongs_to :setting

  def self.get_setting(enity, setting)
    sett = enity.settings.find_by(description: setting)
    if sett
      return sett.user_settings.first
    else
      return false
    end
  end
end
