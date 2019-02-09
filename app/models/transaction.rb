# == Schema Information
#
# Table name: transactions
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)
#  amount         :integer
#  direction      :integer
#  description    :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :integer
#  timezone       :string(255)
#  local_datetime :datetime
#  currency       :string(255)
#

class Transaction < ApplicationRecord
  belongs_to :account
  has_one :user, through: :account
  belongs_to :category, optional: true
  has_one :parent, :class_name => 'Transaction'
  has_many :children, :class_name => 'Transaction', :foreign_key => 'parent_id'

  def self.create_from_list(current_user, transactions)
    transactions.each do |transaction|
      t = self.create_transaction(current_user, transaction)
    end
  end

  def self.create_transaction(current_user, transaction)
    t = Transaction.new
    t.user_id = transaction[:user_id]
    t.amount = transaction[:amount]
    t.description = transaction[:description]
    t.account_id = transaction[:account_id]
    t.timezone = transaction[:timezone]
    t.local_datetime = transaction[:local_datetime]
    t.currency = transaction[:currency]
    t.account_currency_amount = transaction[:account_currency_amount]
    t.category_id = transaction[:category_id]
    t.exclude_from_all = transaction[:exclude_from_all]
    t.parent_id = transaction[:parent_id]
    t.save

    if transaction[:is_child] == false
      Account.add(current_user, transaction[:account_id], transaction[:account_currency_amount])
      Account.record_history(current_user, transaction[:account_id], transaction[:local_datetime])
    end

    return t
  end

  def self.create_from_string(params, current_user)
    transaction = CreateFromString.new(params, current_user).perform
  end

  def self.create_OLD(account_id, params, current_user)
    account_currency = Account.get_currency(Account.find(account_id))

    puts params

    if account_currency.iso_code != params[:currency]
      params[:account_currency_amount] = CurrencyRate.convert(params[:amount], Money::Currency.new(params[:currency]), account_currency)
    else
      params[:account_currency_amount] = params[:amount]
    end

    tz = TZInfo::Timezone.get(params[:timezone])
    params[:local_datetime] = tz.utc_to_local(Time.now)

    transaction = current_user.transactions.new(params)
    transaction.save

    Account.add(current_user, account_id, params[:amount])
  end

  def self.create_OLD2(params, current_user)
    t = self.new
    t.description = params[:transaction][:description]
    t.account_id = current_user.accounts.where(name: params[:transaction][:account]).take.id
    t.currency = params[:transaction][:currency]
    t.user_id = current_user.id
    t.category_id = params[:transaction][:category_id]

    amount = 0
    if params[:transaction][:amount]
      amount = params[:transaction][:amount]
    end

    t.timezone = params[:transaction][:timezone]

    tz = TZInfo::Timezone.get(params[:transaction][:timezone])
    t.local_datetime = tz.utc_to_local(Time.now)

    currency = Money::Currency.new(params[:transaction][:currency])

    if currency.subunit_to_unit > 0
      amount *= currency.subunit_to_unit
    end

    t.save
  end

  def self.create(params, current_user)
    CreateFromForm.new(params, current_user).perform
  end
end
