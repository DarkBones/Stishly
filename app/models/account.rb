# == Schema Information
#
# Table name: accounts
#
#  id          :bigint(8)        not null, primary key
#  balance     :integer
#  currency_id :bigint(8)
#  user_id     :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#  description :string(255)
#  position    :integer
#  currency    :string(255)
#  is_default  :boolean
#

class Account < ApplicationRecord
  validates :name, :user_id, presence: true


  belongs_to :user
  has_many :transactions
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values

  def self.get_accounts(current_user)
    return GetAccounts.new(current_user).perform
  end

  def self.get_transactions(params, current_user)
    return GetTransactions.new(params, current_user).perform
  end

  def self.get_currency(id, current_user)
    if id == 'all'
      return User.get_currency(current_user)
    end

    account = Account.find(id)
    sett = SettingValue.get_setting(account, 'currency')
    if !sett
      sett = SettingValue.get_setting(current_user, 'currency')
    end

    if !sett
      return ISO3166::Country[current_user.country_code].currency
    else
      return Money::Currency.new(sett.value)
    end
  end

  def self.change_setting(account, params, current_user)
    sett_name = params[:setting_value].keys[0].to_s
    sett_value = params[:setting_value].values[0].to_s

    if sett_name == 'currency'
      Account.convert_currency(account, sett_value, current_user)
    end

    SettingValue.save_setting(account, {name: sett_name, value: sett_value})

    return account
  end

  def self.set_default(id, current_user)
    accounts = Account.where(user_id: current_user.id)
    accounts.each do |a|
      a.is_default = a.id.to_i == id.to_i
      a.save
    end
  end

  def self.create_from_string(params, current_user)
    return CreateFromString.new(params, current_user).perform
  end

  def self.create(params, current_user)
    existing_accounts = current_user.accounts.where('name' => params[:name])

    default_account = current_user.accounts.where('is_default' => true)
    if default_account.length > 0
      params[:is_default] = false
    else
      params[:is_default] = true
    end

    if existing_accounts.length == 0
      account = current_user.accounts.build(params)
      account.save

      return account
    else
      return 'Account already exists'
    end
  end

  def self.add(id, amount)
    @balance = Account.find_by_id(id).balance
    @balance += amount

    Account.update(id, :balance => @balance)
  end

  def self.convert_currency(account, new_currency, current_user)
    old_currency = self.get_currency(account.id, current_user)
    balance = self.get_float_balance(account, old_currency)

    new_balance = Concurrency.convert(balance, old_currency.iso_code, new_currency)
    account.balance = self.get_int_balance(new_balance, Money::Currency.new(new_currency))
    account.save
  end

  def self.get_float_balance(account, currency)
    balance = account.balance.to_f
    balance = balance / currency.subunit_to_unit if currency.subunit_to_unit != 0
    return balance
  end

  def self.get_int_balance(balance, currency)
    balance = (balance * currency.subunit_to_unit).round.to_i
    return balance
  end

end
