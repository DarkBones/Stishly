# == Schema Information
#
# Table name: transactions
#
#  id                       :bigint(8)        not null, primary key
#  user_id                  :bigint(8)
#  amount                   :integer
#  direction                :integer
#  description              :string(100)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :integer
#  timezone                 :string(255)
#  currency                 :string(255)
#  account_currency_amount  :integer
#  category_id              :bigint(8)
#  parent_id                :bigint(8)
#  local_datetime           :datetime
#  transfer_account_id      :bigint(8)
#  user_currency_amount     :integer
#  transfer_transaction_id  :integer
#  scheduled_transaction_id :integer
#  is_scheduled             :boolean          default(FALSE)
#  schedule_id              :bigint(8)
#

class Transaction < ApplicationRecord
  belongs_to :account
  has_one :user, through: :account
  belongs_to :category, optional: true
  belongs_to :schedule, optional: true
  has_one :parent, :class_name => 'Transaction'
  has_many :children, :class_name => 'Transaction', :foreign_key => 'parent_id'
  has_and_belongs_to_many :schedules

  attr_reader :rate, :account_currency, :rate_from_to, :to_account_currency, :date, :time, :active_account, :schedule_id, :schedule_type

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc', include_children: 1, is_scheduled: 0 },
    available_filters: [
      :description,
      :from_date,
      :to_date,
      :from_amount,
      :to_amount,
      :account,
      :category_id,
      :include_children,
      :amount_range,
      :period,
      #:in_the_last,
      :sorted_by,
      :is_scheduled,
      :is_queued
    ]
  )

  delegate :name, :to => :account, :prefix => true, :allow_nil => false

  delegate :name, :to => :category, :prefix => true, :allow_nil => true
  #delegate :symbol, :to => :category, :prefix => true, :allow_nil => true
  #delegate :color, :to => :category, :prefix => true, :allow_nil => true

  scope :description, ->(description) { where("UPPER(transactions.description) LIKE ?", "%#{description.upcase}%") }
  scope :from_date, ->(from_date) { where("DATE(local_datetime) >= DATE(?)", from_date.to_date) }
  scope :to_date, ->(to_date) { where("DATE(local_datetime) <= DATE(?)", to_date.to_date) }
  scope :from_amount, ->(from_amount) { where("user_currency_amount >= ?", from_amount) }
  scope :to_amount, ->(to_amount) { where("user_currency_amount >= ?", to_amount) }
  scope :account, ->(account_name) { joins(:account).where("accounts.name = ?", account_name) }
  scope :is_scheduled, ->(scheduled) { where("is_scheduled = 0") }
  scope :is_queued, ->(queued) { where "is_queued = 0" }
  
  scope :period, ->(range){
    
  }

  scope :include_children, ->(value) {
    case value
    when 1
      where("parent_id IS NULL")
    when 2
      where("parent_id IS NOT NULL")
    end
  }

  scope :amount_range, ->(range_str){
    range_str = range_str.split(",")
    where("ABS(user_currency_amount) >= ? AND ABS(user_currency_amount) <= ?", range_str[0], range_str[1])
  }

  scope :category_id, ->(category_id) {
    category_ids = []

    category_ids.push(category_id)

    if category_id != 0

      cat = Category.where(id: category_id).includes(:children).first
      children = Category.get_children(cat)

      children.each do |c|
        category_ids.push(c.id)
      end
    end

    where("category_id in (?)", category_ids)
  }
  
  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^created_at_/
      reorder("transactions.local_datetime #{direction}")
    when /^description_/
      order("LOWER(transactions.description) #{direction}")
    when /^amount_/
      order("ABS(transactions.user_currency_amount) #{direction}")
    when /^account_/
      joins(:account).order("accounts.name #{direction}")
    when /^category_/
      joins(:category).order("category.name #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.update(transaction_id, params, current_user)
    @transactions = UpdateTransaction.new(transaction_id, params, current_user).perform
  end

  def self.create_scheduled_transactions(transaction, current_user)
    return CreateScheduledTransactions.new(transaction, current_user).perform
  end

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

  def self.get_details(transactions, active_account, current_user)
    transaction_amounts_all = []
    account_ids_all = []
    transactions_parent = []
    account_names = []
    date = nil
    update_day_total = false
    total_amount = 0

    transactions.each do |t|

      amount = 0

      amount = get_account_currency_amount(t, active_account)
      date = t.local_datetime.to_s.split[0]

      if active_account.nil? || active_account.id == t.account.id
        update_day_total = true

        unless t.parent_id
          transactions_parent.push(t)
          account_names.push(t.account.name)
          total_amount += amount
          transaction_amounts_all.push(amount)
          account_ids_all.push(t.account.id)
        end
      end
    end

    return {
      transaction_amounts_all: transaction_amounts_all,
      account_ids_all: account_ids_all,
      transactions_parent: transactions_parent,
      account_names: account_names,
      date: date,
      update_day_total: update_day_total,
      total_amount: total_amount
    }
  end

  def self.get_account_currency_amount(transaction, active_account)
    #return 0 if transaction.account_currency_amount.nil?
    return transaction.user_currency_amount if active_account.nil?
    return transaction.account_currency_amount
  end

  def self.get_user_currency_amount(transaction, account_name, current_user)
    user_currency = User.get_currency(current_user)

    amount = transaction.account_currency_amount
    if transaction.currency != user_currency.iso_code && account_name == ''
      amount = CurrencyRate.convert(amount, Money::Currency.new(transaction.currency), user_currency)
    end

    return amount
  end

  def self.create_from_string(params, current_user)
    CreateFromString.new(params, current_user).perform
  end

  def self.create(params, current_user)
    transactions = CreateFromForm.new(params, current_user).perform
    transactions = SaveTransactions.new(transactions, current_user).perform

    transactions.each do |t|
      Account.add(current_user, t.account_id, t.account_currency_amount) if t.parent_id.nil? && !t.is_scheduled
    end
  end

  def self.create_from_schedule(transaction, schedule)
    transactions = CreateScheduledTransactions.new(transaction, schedule.user, schedule, false, schedule.timezone).perform
    return transactions
  end

  def self.join_to_schedule(transaction, schedule)
    main_transaction = transaction
    main_transaction = Transaction.find(transaction.parent_id) unless transaction.parent_id.nil?

    return if !main_transaction.transfer_transaction_id.nil? && main_transaction.direction == 1

    transaction.schedules << schedule
  end

end
