class Setting < ApplicationRecord
  has_many :user_settings

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
