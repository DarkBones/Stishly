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
#

class Account < ApplicationRecord
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

  def self.add(id, amount)
    @balance = Account.find_by_id(id).balance
    @balance += amount

    Account.update(id, :balance => @balance)
  end

  def self.convert_currency(account, new_currency, current_user)
    old_currency = self.get_currency(account.id, current_user).iso_code
    new_balance = Concurrency.convert(account.balance, old_currency, new_currency)
    account.balance = new_balance
    account.save
  end

end
