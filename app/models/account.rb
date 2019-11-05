# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  balance      :integer          default(0)
#  user_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string(255)      not null
#  description  :string(255)
#  position     :integer
#  currency     :string(255)      not null
#  is_default   :boolean
#  account_type :string(255)      default("spend")
#  hash_id      :string(255)
#  is_disabled  :boolean          default(FALSE)
#

class Account < ApplicationRecord
  include Friendlyable
  extend FriendlyId

  
  validates :name, presence: { message: I18n.t('account.failure.no_name') }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false, message: I18n.t('account.failure.already_exists') }
  validates :currency, presence: true
  validate :plan, :on => :create
  validate :plan_update, :on => :update


  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values
  has_many :account_histories, dependent: :destroy
  has_many :sch_transactions

  # returns the spending balance of a user. If a date is provided, it returns the balance as it was on the start of that date
  def self.get_spend_balance(user, date: nil)
    balance = 0

    if date.nil?
      user.accounts.where(account_type: 'spend').each do |a|
        balance += CurrencyRate.convert(a.balance, a.currency, user.currency)
      end
    else
      user.accounts.where(account_type: 'spend').each do |a|
        history = a.account_histories.where(
          "date(local_datetime) <= ?", 
          date).order(:local_datetime).reverse_order.take
        history ||= a.account_histories.order(:local_datetime).take

        balance += CurrencyRate.convert(history.balance, a.currency, user.currency)
      end
    end

    return balance

  end

  def self.delete(account)
    # decouple transfer transactions
    transfer_transactions = account.transactions.where("transfer_transaction_id is not null")
    transfer_transactions.each do |tt|
      transaction = tt.transfer_transaction
      unless transaction.nil?
        transaction.transfer_transaction_id = nil
        transaction.transfer_account_id = nil
        transaction.save
      end
    end

    # delete account transactions
    account.transactions.destroy_all

    # delete the account
    account.destroy
  end

  def self.update_account(account, params)
    currency = Money::Currency.new(account.currency)
    balance = params[:balance].to_f * currency.subunit_to_unit
    params[:balance] = balance.to_i

    # name 'new' not allowed
    if params[:name] == 'new'
      params[:name] = 'New'
    end

    if balance != account.balance
      transaction = Transaction.create_balancer(account, balance)
      self.add(transaction.account, transaction.amount, transaction.local_datetime)
    end

    params[:slug] = GenerateSlug.new(account.user, params[:name]).perform

    return account.update(params)

  end

  def self.day_total(account, user, date)
    if account.nil?
      return user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND is_scheduled = false", date).sum(:user_currency_amount)
    else
      return account.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND is_scheduled = false", date).sum(:account_currency_amount)
    end
  end

  def self.get_from_name(name, current_user)
    if name
      account = current_user.accounts.where(slug: name).take
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

  # TODO: Optimize add and subtract into a single function
  def self.add(account, amount, local_datetime)
    return if amount.nil?

    balance = account.balance
    balance += amount

    #account = Account.update(account.id, :balance => balance)
    account.balance = balance
    account.save

    history = account.account_histories.create({
      local_datetime: local_datetime,
      balance: account.balance
    })

    account.account_histories.where("local_datetime >= ? AND id != ?", local_datetime, history.id).each do |history|
      history.balance = history.balance + amount
      history.save
    end

  end

  def self.subtract(current_user, account, amount, local_datetime)
    return if amount.nil?

    balance = account.balance
    balance -= amount
    Account.update(account.id, :balance => balance)

    account.account_histories.where("local_datetime >= ?", local_datetime).each do |history|
      history.balance = history.balance - amount
      history.save
    end
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

  def plan
    plan = APP_CONFIG['plans'][user.subscription]
    plan ||= APP_CONFIG['plans']['free']

    accounts = user.accounts.where("id IS NOT NULL AND is_disabled = false")

    if accounts.length >= plan['max_accounts']
      errors.add(:Plan, "<a href='/plans'>" + I18n.t('account.failure.upgrade_for_accounts') + "</a>") unless plan['max_accounts'] < 0
    elsif account_type == 'spend'
      if accounts.where(account_type: 'spend').length >= plan['max_spending_accounts']
        errors.add(:Plan, "<a href='/plans'>" + I18n.t('account.failure.upgrade_for_spending') + "</a>") unless plan['max_spending_accounts'] < 0
      end
    end

  end

  def plan_update
    plan = APP_CONFIG['plans'][user.subscription]
    plan ||= APP_CONFIG['plans']['free']

    accounts = user.accounts.where("id IS NOT NULL AND is_disabled = false")

    if accounts.length > plan['max_accounts']
      errors.add(:Plan, "<a href='/plans'>" + I18n.t('account.failure.upgrade_for_accounts') + "</a>") unless plan['max_accounts'] < 0
    elsif account_type == 'spend'
      if accounts.where(account_type: 'spend').length > plan['max_spending_accounts']
        errors.add(:Plan, "<a href='/plans'>" + I18n.t('account.failure.upgrade_for_spending') + "</a>") unless plan['max_spending_accounts'] < 0
      end
    end

  end

end
