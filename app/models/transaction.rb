# == Schema Information
#
# Table name: transactions
#
#  id                      :bigint(8)        not null, primary key
#  user_id                 :bigint(8)
#  amount                  :integer
#  direction               :integer
#  description             :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  account_id              :integer
#  timezone                :string(255)
#  currency                :string(255)
#  account_currency_amount :integer
#  category_id             :bigint(8)
#  parent_id               :bigint(8)
#  exclude_from_all        :boolean          default(FALSE)
#  local_datetime          :datetime
#  transfer_account_id     :bigint(8)
#

class Transaction < ApplicationRecord
  belongs_to :account
  has_one :user, through: :account
  belongs_to :category, optional: true
  has_one :parent, :class_name => 'Transaction'
  has_many :children, :class_name => 'Transaction', :foreign_key => 'parent_id'
  has_many :schedule_joins
  has_many :schedules, through: :schedule_joins

  def self.prepare_new(params, current_user)
    """
    needed parameters:
    - d_formatted
    - account_currency
    - account_balance
    """
    account = Account.get_from_name(params[:account], current_user)
    return {
      d_formatted: User.format_date(params[:date].to_date),
      account_currency: account.currency,
      account_balance: account.balance
    }
  end

  def self.create_from_list(current_user, transactions)
    result = []
    transactions.each do |transaction|
      if transaction.is_a? Hash
        t = self.create_transaction(current_user, transaction)
      elsif transaction.is_a? Transaction
        t = transaction
      end

      result.push(t.decorate)
    end
    
    return result
  end

  def self.create_transaction(current_user, transaction)
    t = Transaction.new
    t.user_id = transaction[:user_id]
    t.amount = transaction[:amount]
    t.direction = transaction[:direction]
    t.description = transaction[:description]
    t.account_id = transaction[:account_id]
    t.timezone = transaction[:timezone]
    t.local_datetime = transaction[:local_datetime]
    t.currency = transaction[:currency]
    t.account_currency_amount = transaction[:account_currency_amount]
    t.category_id = transaction[:category_id]
    t.exclude_from_all = transaction[:exclude_from_all]
    t.parent_id = transaction[:parent_id]
    t.transfer_account_id = transaction[:transfer_account]
    t.save

    if transaction[:is_child] == false
      Account.add(current_user, transaction[:account_id], transaction[:account_currency_amount])
      Account.record_history(current_user, transaction[:account_id], transaction[:local_datetime])
    end

    return t
  end

  def self.create_from_string(params, current_user)
    CreateFromString.new(params, current_user).perform
  end

  def self.create(params, current_user)
    CreateFromForm.new(params, current_user).perform
  end
end
