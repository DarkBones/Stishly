# == Schema Information
#
# Table name: transactions
#
#  id                       :bigint           not null, primary key
#  user_id                  :bigint
#  amount                   :integer
#  direction                :integer
#  description              :string(100)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :integer
#  timezone                 :string(255)
#  currency                 :string(255)
#  account_currency_amount  :integer
#  category_id              :bigint
#  parent_id                :bigint
#  local_datetime           :datetime
#  transfer_account_id      :bigint
#  user_currency_amount     :integer
#  transfer_transaction_id  :integer
#  scheduled_transaction_id :integer
#  is_scheduled             :boolean          default(FALSE)
#  schedule_id              :bigint
#  queue_scheduled          :boolean          default(FALSE)
#  is_queued                :boolean          default(FALSE)
#  schedule_period_id       :integer
#

class Transaction < ApplicationRecord

  belongs_to :account
  has_one :user, through: :account
  belongs_to :category, optional: true
  belongs_to :schedule, optional: true
  has_one :parent, :class_name => 'Transaction'
  has_many :children, :class_name => 'Transaction', :foreign_key => 'parent_id'
  has_and_belongs_to_many :schedules
  has_one :transfer_transaction, :class_name => 'Transaction', :foreign_key => 'transfer_transaction_id'

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

  scope :description, ->(description) { where("UPPER(transactions.description) LIKE ?", "%#{description.upcase}%") }
  scope :from_date, ->(from_date) { where("DATE(local_datetime) >= DATE(?)", from_date.to_date) }
  scope :to_date, ->(to_date) { where("DATE(local_datetime) <= DATE(?)", to_date.to_date) }
  scope :from_amount, ->(from_amount) { where("user_currency_amount >= ?", from_amount) }
  scope :to_amount, ->(to_amount) { where("user_currency_amount >= ?", to_amount) }
  scope :account, ->(account_name) { joins(:account).where("accounts.name = ?", account_name) }
  scope :is_scheduled, ->(scheduled) { where("is_scheduled = ?", scheduled) }
  scope :is_queued, ->(queued) { where("is_queued = ?", queued) }
  
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

  def self.update_upcoming_occurrence(params, current_user, transaction)
    transactions = CreateFromForm.new(params, current_user).perform
    transactions = SaveTransactions.new(transactions, current_user, false).perform

    unless transaction.scheduled_transaction_id.nil?
      transaction.destroy
    end

    return transactions
  end

  # takes a transaction and returns its main transaction (ie the parent and, if transfer, the outgoing one)
  def self.find_main_transaction(transaction)
    if transaction.class == Array
      transaction = transaction[0]
    end

    transaction = transaction.parent unless transaction.parent_id.nil?
    
    unless transaction.transfer_transaction_id.nil?
      transaction = transaction.transfer_transaction if transaction.direction == 1
    end

    return transaction
  end

  def self.cancel_upcoming_occurrence(current_user, transaction, schedule_id, schedule_period_id)
    # if the transaction already exists, it means that it was edited and is_cancelled can simply be set to true
    unless transaction.scheduled_transaction_id.nil?
      transaction.is_cancelled =  true
      transaction.save
      return
    end

    scheduled_transaction_id = transaction.id

    transaction = transaction.dup

    transaction.schedule_id = schedule_id
    transaction.schedule_period_id = schedule_period_id
    transaction.is_cancelled = true
    transaction.scheduled_transaction_id = scheduled_transaction_id
    transaction.save
  end

  def self.uncancel_upcoming_occurrence(transaction)
    transaction.is_cancelled = false
    transaction.save
  end

  def self.trigger_upcoming_occurrence(current_user, transaction, schedule, schedule_period_id)
    scheduled_transaction_id = transaction.scheduled_transaction_id
    scheduled_transaction_id ||= transaction.id

    transactions = CreateScheduledTransactions.new(transaction, current_user, scheduled_transaction_id, schedule, false, current_user.timezone, schedule_period_id).perform
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

    timezone = transactions[0].timezone if transactions.length > 0

    if timezone != current_user.timezone
      current_user.timezone = timezone
      current_user.save
    end

    transactions.each do |t|
      Account.add(current_user, t.account_id, t.account_currency_amount, t.local_datetime) if t.parent_id.nil? && !t.is_scheduled
    end
  end

  def self.create_from_schedule(transaction, schedule, scheduled_transaction_id)
    transactions = CreateScheduledTransactions.new(transaction, schedule.user, scheduled_transaction_id, schedule, false, schedule.timezone).perform
    return transactions
  end

  def self.join_to_schedule(transaction, schedule)
    main_transaction = transaction
    main_transaction = Transaction.find(transaction.parent_id) unless transaction.parent_id.nil?

    return if !main_transaction.transfer_transaction_id.nil? && main_transaction.direction == 1

    transaction.schedules << schedule
  end

  def self.approve_transaction(transaction, params)
    transaction.description = params[:description]
    transaction.amount = convert_float_to_i_amount(params[:amount], transaction.currency)
    params[:account_currency_amount].nil? ? transaction.account_currency_amount = convert_float_to_i_amount(params[:amount], transaction.currency) : transaction.account_currency_amount = convert_float_to_i_amount(params[:account_currency_amount], transaction.account.currency)
    params[:user_currency_amount].nil? ? transaction.user_currency_amount = convert_float_to_i_amount(params[:amount], transaction.currency) : transaction.user_currency_amount = convert_float_to_i_amount(params[:user_currency_amount], transaction.user.currency)

    transaction.is_queued = false
    transaction.save!

    Account.add(transaction.user, transaction.account.id, transaction.account_currency_amount, transaction.local_datetime)
  end

private
  def self.convert_float_to_i_amount(amount, currency)
    currency = Money::Currency.new(currency) if currency.class == String

    amount = amount.to_f
    return (amount * currency.subunit_to_unit).round.to_i
  end

end
