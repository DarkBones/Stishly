# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  balance      :integer          default(0)
#  currency_id  :bigint
#  user_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string(255)      not null
#  description  :string(255)
#  position     :integer
#  currency     :string(255)      not null
#  is_default   :boolean
#  account_type :string(255)      default("spend")
#

class Account < ApplicationRecord
  validates :name, presence: true
  validates :name, format: { without: /[-\._~:\/\?#\[\]@!\$&'\(\)\*\+,;={}"]/, message: "Special characters not allowed" }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false, message: I18n.t('account.failure.already_exists') }
  validates :currency, presence: true
  validate :subscription


  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values
  has_many :account_histories, dependent: :destroy
  has_many :sch_transactions

  def self.get_from_name(name, current_user)
    if name
      account = current_user.accounts.where(name: name).take()
    else
      account = self.create_summary_account(current_user, true)
    end
    return account
  end

  def self.get_accounts(current_user)
    return GetAccounts.new(current_user).perform
  end

  def self.get_transactions(account, page, current_user)
    return GetTransactions.new(account, page, current_user).perform
  end

  def self.get_daily_totals(account_id, transactions, current_user)
    return GetDailyTotals.new(account_id, transactions, current_user).perform
  end

  def self.get_display_balance_html(params)
    Money.locale_backend = :i18n

    amount = params[:amount].to_i
    add = params[:add].to_i
    if params[:from] != params[:to]
      add = CurrencyRate.convert(add, Money::Currency.new(params[:from]), Money::Currency.new(params[:to]))
    end
    amount += add

    balance = Money.new(amount, params[:to]).format

    balance = balance.split('.')

    if balance.length > 1
      result = balance[0...-1][0]
    else
      result = balance[0]
    end

    if balance[1]
      result += '.<span class="cents">'
      result += balance[1]
      result += '</span>'
    end

    output = {
      html: result,
      balance: amount,
      add:add
    }

    return output
  end

  def self.create_summary_account(current_user, include_balance = false)
    account = Account.new
    account.id = 0
    account.name = 'All'
    account.user_id = current_user.id
    account.currency = User.get_currency(current_user).iso_code

    if include_balance
      account.balance = self.get_total_balance(current_user)
    end

    return account
  end

  def self.get_total_balance(current_user)
    total_balance = 0
    user_currency = User.get_currency(current_user)
    current_user.accounts.each do |a|
      balance = a.balance
      if a.currency != user_currency.iso_code
        balance = CurrencyRate.convert(a.balance, Money::Currency.new(a.currency), user_currency)
      end
      total_balance += balance
    end
    return total_balance
  end

  def self.format_currency(amount, currency_iso)
    return Money.new(amount, currency_iso).format
  end

  def self.format_currency_float(amount, currency_iso)
    currency = Money::Currency.new(currency_iso)
    amount = amount.to_f
    amount *= currency.subunit_to_unit

    return Money.new(amount, currency_iso).format
  end

  def self.get_currency_from_name(account_name, current_user)
    account = self.get_from_name(account_name, current_user)
    currency = self.get_currency(account)
    return currency
  end

  def self.get_currency(account)
    return Money::Currency.new(account.currency)
  end

  # if account is found, returns the account currency. Otherwise, returns the user's currency
  def self.get_account_or_user_currency(account_name, current_user)
    account = self.get_from_name(account_name, current_user)
    if account
      return account.currency
    else
      return User.get_currency(current_user).iso_code
    end
  end

  def self.change_setting(account, params)
    sett_name = params[:setting_value].keys[0].to_s
    sett_value = params[:setting_value].values[0].to_s

    SettingValue.save_setting(account, {name: sett_name, value: sett_value})

    if sett_name == 'currency'
      account.currency = sett_value
      account.save
    end

    return account
  end

  def self.set_default(id, current_user)
    accounts = Account.where(user_id: current_user.id)
    accounts.each do |a|
      a.is_default = a.id.to_i == id.to_i
      a.save
    end
  end

  def self.get_default(current_user)
    current_user.accounts.where(is_default: true).take
  end

  def self.create_from_string(params, current_user)
    return CreateFromString.new(params, current_user).perform
  end

  def self.create_new(params, current_user)
    return NewAccount.new(params, current_user).perform
  end

  def self.create(params, current_user)
    user_currency = User.get_currency(current_user)

    default_account = current_user.accounts.where('is_default' => true)
    if default_account.length > 0
      params[:is_default] = false
    else
      params[:is_default] = true
    end

    unless params[:currency]
      params[:currency] = user_currency.iso_code
    end

    if current_user.accounts.order(:position).first
      position = current_user.accounts.order(:position).first.position
    else
      position = 1
    end

    if !position.nil?
      params[:position] = position - 1
    else
      params[:position] = 0
    end

    account = current_user.accounts.build(params)

    if account.save
      tz = TZInfo::Timezone.get(current_user.timezone)
      local_datetime = tz.utc_to_local(Time.now.utc)

      account.account_histories.create({
        local_datetime: local_datetime,
        balance: account.balance
      })
    end

    return account
  end

  def self.add(current_user, id, amount, local_datetime)
    return if amount.nil?
    
    account = current_user.accounts.find_by_id(id)

    balance = account.balance
    balance += amount

    Account.update(id, :balance => balance)

    history = account.account_histories.create({
      local_datetime: local_datetime,
      balance: account.balance
    })
    history.save
  end

  def self.record_history(current_user, id, local_datetime)
    account = current_user.accounts.find_by_id(id)

    histories = account.account_histories.new
    histories.account_id = account.id
    histories.balance = account.balance
    histories.local_datetime = local_datetime
    histories.save
  end

private

  def subscription
    subscription_tier = user.subscription_tier if user.subscription_tier_id > 0
    subscription_tier ||= SubscriptionTier.where(name: "Free").take()
    return unless subscription_tier

    if user.accounts.length >= subscription_tier.max_accounts
      
      errors.add(:account, "Upgrade to premium for more accounts") unless subscription_tier.max_accounts < 0
    elsif account_type == "spend"
      if user.accounts.where(account_type: "spend").length >= subscription_tier.max_spending_accounts
        errors.add(:account, "Upgrade to premium for more spending accounts") unless subscription_tier.max_accounts < 0
      end
    end

  end

end
