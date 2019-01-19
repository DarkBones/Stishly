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
  
  def self.create_transaction(details, current_user, self_called = false)
    require 'yaml'
    puts details.to_yaml
    puts '//////////////////////////////'
    puts details[:transactions][:transactions].length
    
    if details[:multiple_transactions] == 1
      parent_t = Transaction.new
      parent_t.description = details[:description]
      if !self_called
        parent_t.amount = details[:transactions][:total_amount]
      else
        parent_t.amount = details[:transactions][:total_amount] * -1
      end
      
      parent_t.user_id = details[:user_id]
      if details[:type] == 'transfer'
        if !self_called
          parent_t.account_id = details[:accounts][:to_account].id
        else
          parent_t.account_id = details[:accounts][:from_account].id
        end
      else
        parent_t.account_id = details[:accounts][:account].id
      end

      parent_t.timezone = details[:timezone]
      parent_t.local_datetime = details[:local_datetime]
      parent_t.currency = details[:currency].iso_code
      
      #if !self_called
      #  parent_t.account_currency_amount = details[:transactions][:account_currency_total_amount]
      #else
      #  parent_t.account_currency_amount = details[:transactions][:account_currency_total_amount] * -1
      #end
      
      if details[:type] == 'transfer'
        if !self_called
          parent_t.account_currency_amount = details[:transactions][:account_currency_total_amount][:account_currency_amount_from]
          self.add(details[:accounts][:to_account].id, details[:transactions][:account_currency_total_amount][:account_currency_amount_from])
          self.create_transaction(details, current_user, true)
        else
          parent_t.account_currency_amount = details[:transactions][:account_currency_total_amount][:account_currency_amount_to] * -1
          self.add(details[:accounts][:from_account].id, details[:transactions][:account_currency_total_amount][:account_currency_amount_to] * -1)
        end
      else
        parent_t.account_currency_amount = details[:transactions][:account_currency_total_amount][:account_currency_amount]
        self.add(details[:accounts][:account].id, details[:transactions][:account_currency_total_amount][:account_currency_amount])
      end

      parent_t = parent_t.save
      
      details[:transactions][:transactions].each do |t|
        sub_t = Transaction.new
        
        sub_t.description = t[:description]
        sub_t.user_id = t[:user_id]
        
        if details[:type] == 'transfer'
          if !self_called
            sub_t.amount = t[:amount] * -1
            sub_t.account_currency_amount = t[:account_currency_amounts][:account_currency_amount_from] * -1
            sub_t.account_id = details[:accounts][:from_account].id
          else
            sub_t.amount = t[:amount]
            sub_t.account_currency_amount = t[:account_currency_amounts][:account_currency_amount_to]
            sub_t.account_id = details[:accounts][:to_account].id
          end
        else
          sub_t.amount = t[:amount]
          sub_t.account_currency_amount = t[:account_currency_amounts][:account_currency_amount]
          sub_t.account_id = details[:accounts][:account].id
        end
        
        sub_t.timezone = details[:timezone]
        sub_t.local_datetime = details[:local_datetime]
        sub_t.currency = details[:currency].iso_code
        #sub_t.parent_id = parent_t.id
        
        sub_t.save
      end
      
    else
      t = Transaction.new
      t.description = details[:description]
      t.amount = details[:transactions][:total_amount]
      t.user_id = details[:user_id]
      
      if details[:type] == 'transfer'
        if !self_called
          t.account_id = details[:accounts][:from_account].id
        else
          t.account_id = details[:accounts][:to_account].id
        end
      else
        t.account_id = details[:accounts][:account].id
      end
      
      t.timezone = details[:timezone]
      t.local_datetime = details[:local_datetime]
      t.currency = details[:currency].iso_code
      
      #if !self_called
        #t.account_currency_amount = details[:transactions][:]
    end
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

  def self.create_summary_account(current_user)
    account = Account.new
    account.id = 0
    account.is_real = false
    account.name = 'All'
    account.user_id = current_user.id
    account.currency = User.get_currency(current_user).iso_code

    return account
  end

  def self.get_currency(account)

    return Money::Currency.new(account.currency)
  end

  def self.change_setting(account, params, current_user)
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
    NewAccount.new(params, current_user).perform
  end

  def self.create(params, current_user)
    existing_accounts = current_user.accounts.where('name' => params[:name])

    default_account = current_user.accounts.where('is_default' => true)
    if default_account.length > 0
      params[:is_default] = false
    else
      params[:is_default] = true
    end

    if !params[:currency]
      params[:currency] = User.get_currency(current_user).iso_code
    end

    if existing_accounts.length == 0
      account = current_user.accounts.build(params)
      account.save

      return account
    else
      return I18n.t('account.failure.already_exists')
    end
  end

  def self.add(id, amount)
    @balance = Account.find_by_id(id).balance
    @balance += amount

    Account.update(id, :balance => @balance)
  end

  #def self.convert_currency(account, new_currency, current_user)
  #  old_currency = self.get_currency(account.id, current_user)
  #  balance = self.get_float_balance(account, old_currency)

  #  new_balance = Concurrency.convert(balance, old_currency.iso_code, new_currency)
  #  account.balance = self.get_int_balance(new_balance, Money::Currency.new(new_currency))
  #  account.save
  #end

  #def self.get_float_balance(account, currency)
  #  balance = account.balance.to_f
  #  balance = balance / currency.subunit_to_unit if currency.subunit_to_unit != 0
  #  return balance
  #end

  #def self.get_int_balance(balance, currency)
  #  balance = (balance * currency.subunit_to_unit).round.to_i
  #  return balance
  #end

end
