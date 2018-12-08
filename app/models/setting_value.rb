# == Schema Information
#
# Table name: setting_values
#
#  id          :bigint(8)        not null, primary key
#  entity_id   :bigint(8)
#  setting_id  :bigint(8)
#  value       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_type :string(255)
#

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
