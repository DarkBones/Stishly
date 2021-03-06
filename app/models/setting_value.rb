# == Schema Information
#
# Table name: setting_values
#
#  id          :bigint           not null, primary key
#  entity_id   :bigint
#  setting_id  :bigint
#  value       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_type :string(255)
#

class SettingValue < ApplicationRecord
  belongs_to :entity, :polymorphic => true
  belongs_to :setting

  def self.get_setting(entity, setting)
    sett = entity.settings.find_by(description: setting)
    if sett
      return sett.setting_values.where(entity_id: entity.id).first
    else
      return false
    end
  end

  def self.save_setting(entity, s)
    sett = SettingValue.get_setting(entity, s[:name])
    if !sett
      setting = Setting.get_or_create_setting(s[:name])
      if setting
        new_setting = entity.setting_values.new()
        new_setting.setting_id = setting.id
        new_setting.value = s[:value]
        new_setting.save
      end
    else
      sett.update(value: s[:value])
    end
  end
end
