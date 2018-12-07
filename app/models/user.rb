# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  subscription_tier_id   :bigint(8)        default(1)
#  country_id             :bigint(8)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  timezone               :string(255)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  has_many :transactions, through: :accounts
  has_many :accounts
  has_many :user_settings
  belongs_to :subscription_tier
  has_many :schedules
  
  # Returns the currency (string) of a user
  def self.get_currency(current_user)
    user_setting = current_user.user_settings.find_by(settings_id: Setting.find_by(description: 'currency'))
    if !user_setting
      user_currency = ISO3166::Country[current_user.country_code].currency.iso_code
    else
      user_currency = user_setting.value
    end
    return user_currency
  end

  def self.save_setting(current_user, s)

    user_setting = current_user.user_settings.find_by(settings_id: Setting.find_by(description: s[:name]))
    if !user_setting
      puts '//////////////////................/////////////'
      puts s
      new_setting = UserSetting.new(user_id: current_user.id, settings_id: Setting.find_by(description: s[:name]).id, value:s[:value])
      #new_setting = current_user.user_setting.new(user_id: current_user.id, settings_id: Setting.find_by(description: s[:name]), value:s[:value])
      #new_setting = UserSetting.new({user_id: 20, settings_id: 1, value: 'CAD'})
      puts new_setting
      new_setting.save
    else
      puts '................/////////////////..............'
      puts user_setting.value
      #user_setting.value = s[:value]
      user_setting.update(value: s[:value])
      puts user_setting.value
      #user_setting.save
    end
  end
end
