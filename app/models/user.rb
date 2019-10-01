# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  first_name_enc         :binary(65535)
#  last_name_enc          :binary(65535)
#  subscription_tier_id   :bigint           default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
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
#  timezone               :string(255)      default("Europe/London")
#  country_code           :string(255)
#  country_id             :bigint
#  currency               :string(255)      default("USD")
#  finished_setup         :boolean          default(FALSE)
#  encrypted_email        :string(255)
#  encrypted_email_iv     :string(255)
#  email_bidx             :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#

class User < ApplicationRecord
  include Friendlyable
  
  kms_attr :first_name, key_id: Rails.application.credentials.aws[:kms_key_id]
  kms_attr :last_name, key_id: Rails.application.credentials.aws[:kms_key_id]

  devise :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  attr_encrypted :email, key: [ENV["EMAIL_ENCRYPTION_KEY"]].pack("H*")
  blind_index :email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  has_many :accounts, dependent: :destroy
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values
  belongs_to :subscription_tier, optional: :true
  has_many :schedules, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transactions, through: :accounts
  has_many :account_histories, through: :accounts
  has_many :sch_transactions
  belongs_to :country, optional: :true
  has_many :notifications

  validates :first_name, :last_name, presence: true
  validates :email, uniqueness: true

  # password requirements
  validates :password, password_strength: true, :on => :create
  validates :password, password_strength: {use_dictionary: true}, :on => :create

  after_create :initialize_user_data

  def will_save_change_to_email?
  end

  def self.daily_budget(user)
    return CalculateDailyBudget.new(user).perform
  end

  def self.from_omniauth(auth)
    puts auth.to_yaml
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name

      return user
    end
  end

  def self.set_current_user(current_user)
    @current_user = current_user
  end

  def self.setup_user(current_user, params)
    SetupUserData.new(current_user, params).perform
  end

  def self.current_time
    tz = TZInfo::Timezone.get(@current_user.timezone)

    return tz.utc_to_local(Time.now.utc)
  end

  def self.format_date(d, include_weekday=false, today_names=false)
    tz = TZInfo::Timezone.get(@current_user.timezone)

    if today_names
      today = tz.utc_to_local(Time.now.utc).to_date
      yesterday = tz.utc_to_local(Time.now.utc).to_date - 1.day
      tomorrow = tz.utc_to_local(Time.now.utc).to_date + 1.day

      if d == today
        return I18n.t('dates.today')
      end

      if d == yesterday
        return I18n.t('dates.yesterday')
      end

      if d == tomorrow
        return I18n.t('dates.tomorrow')
      end
    end

    date_format = self.get_dateformat

    date_format.sub! "dd", "%d"
    date_format.sub! "d", "%-d" unless date_format.include? "%d"
    date_format.sub! "mmmm", "%B"
    date_format.sub! "mmm", "%b"
    date_format.sub! "mm", "%m"
    date_format.sub! "m", "%-m" unless date_format.include? "%m"
    date_format.sub! "yyyy", "%Y"
    date_format.sub! "yy", "%y"

    if include_weekday
      date_format = "%a, " + date_format
    end

    return d.strftime(date_format)
  end

  def self.get_dateformat
    user_setting = SettingValue.get_setting(@current_user, "date_format")

    if user_setting
      return user_setting.value
    else
      return Country.get_dateformat(@current_user.country_code)
    end
  end

  # Returns the currency (string) of a user
  def self.get_currency(current_user)
    return Money::Currency.new(current_user.currency)
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

    Sendgrid.new(self).add_to_marketing if Rails.env.production?
  end
end
