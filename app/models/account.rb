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

  def self.get_accounts(current_user)
    return GetAccounts.new(current_user).perform
  end

  def self.get_transactions(params, current_user)
    return GetTransactions.new(params, current_user).perform
  end

  def self.get_currency(id, current_user)
    if id != 'all'
      acc_currency = Account.find_by_id(id).currency
      if acc_currency == nil
        return User.get_currency(current_user)
      else
        return Money::Currency.new(acc_currency)
      end
    else
      return User.get_currency(current_user)
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

end
