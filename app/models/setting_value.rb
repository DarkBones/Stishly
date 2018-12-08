class SettingValue < ApplicationRecord
  belongs_to :entity, :polymorphic => true
  belongs_to :setting

  def self.get_setting(enity, setting)
    sett = enity.settings.find_by(description: setting)
    if sett
      return sett.setting_values.first
    else
      return false
    end
  end
end
