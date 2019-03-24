# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  subscription_tier_id   :bigint(8)        default(1)
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
#  country_code           :string(255)
#  country_id             :bigint(8)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  has_many :accounts, dependent: :destroy
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values
  belongs_to :subscription_tier
  has_many :schedules, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transactions, through: :accounts
  has_many :account_histories, through: :accounts
  belongs_to :country, optional: :true

  validates :country_code, :first_name, :last_name, presence: true

  after_create :initialize_user_data

  def self.set_current_user(current_user)
    @current_user = current_user
  end

  def self.format_date(d, include_weekday=false)
    tz = TZInfo::Timezone.get(@current_user.timezone)
    today = tz.utc_to_local(Time.now).to_date
    yesterday = tz.utc_to_local(Time.now).to_date - 1.day

    if d == today
      return I18n.t('dates.today')
    end

    if d == yesterday
      return I18n.t('dates.yesterday')
    end

    date_format = self.get_dateformat

    month_no_padding = d.month.to_s
    day_no_padding = d.day.to_s

    date_format.sub! "dd", "%d"
    date_format.sub! "d", "%-d" if !date_format.include? "%d"
    date_format.sub! "mmmm", "%B"
    date_format.sub! "mmm", "%b"
    date_format.sub! "mm", "%m"
    date_format.sub! "m", "%-m" if !date_format.include? "%m"
    date_format.sub! "yyyy", "%Y"
    date_format.sub! "yy", "%y"

    if include_weekday
      date_format = "%a, " + date_format
    end

    #return d.strftime("%d %b %Y")
    return d.strftime(date_format)
  end

  def self.get_dateformat
    user_setting = SettingValue.get_setting(@current_user, "date_format")

    if user_setting
      return user_setting.value
    else
      country_setting = Country.get_dateformat(@current_user.country_code)
    end
  end

  # Returns the currency (string) of a user
  def self.get_currency(current_user)
    sett = SettingValue.get_setting(current_user, 'currency')
    if !sett
      return ISO3166::Country[current_user.country_code].currency
    else
      return Money::Currency.new(sett.value)
    end
  end

  def self.change_setting(current_user, params)
    sett_name = params[:setting_value].keys[0].to_s
    sett_value = params[:setting_value].values[0].to_s

    SettingValue.save_setting(current_user, {name: sett_name, value: sett_value})

    return current_user
  end

  def initialize_user_data
    country = Country.where(country_code: self.country_code).take()
    if country
      self.country_id = country.id
      self.save
    end
    InitializeUserData.new(self).perform
  end
end
