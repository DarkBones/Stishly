# == Schema Information
#
# Table name: settings
#
#  id          :bigint(8)        not null, primary key
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Setting < ApplicationRecord
  has_many :setting_values

  def self.get_or_create_setting(description)
    sett = Setting.find_by(description: description)
    if !sett
      new_sett = Setting.new(description: description)
      new_sett.save
      return new_sett
    else
      return sett
    end
  end
end
