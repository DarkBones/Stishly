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
      :is_queued,
      :is_balancer
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
  scope :is_balancer, -> (balancer) { where("is_balancer = ?", balancer) }
  
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

  def self.create_balancer(account, target)
    tz = TZInfo::Timezone.get(account.user.timezone)
    amount = target - account.balance
    user_amount = CurrencyRate.convert(amount.to_i, account.currency, account.user.currency)
    if amount < 0
      direction = -1
    else
      direction = 1
    end

    transaction = self.new
    transaction.user_id = account.user.id
    transaction.currency = account.currency
    transaction.timezone = account.user.timezone
    transaction.account_currency_amount = amount
    transaction.user_currency_amount = user_amount
    transaction.account_id = account.id
    transaction.is_balancer = true
    transaction.local_datetime = tz.utc_to_local(Time.now.utc)
    transaction.amount = amount
    transaction.direction = direction

    transaction.save!

  end

  def self.delete(transaction, current_user)
    return if transaction.nil?

    main_transaction = self.find_main_transaction(transaction)
    transfer_transaction = main_transaction.transfer_transaction

    deleted_transactions = []

    unless main_transaction.is_scheduled
      Account.subtract(current_user, main_transaction.account, main_transaction.account_currency_amount, main_transaction.local_datetime)
      Account.subtract(current_user, transfer_transaction.account, transfer_transaction.account_currency_amount, transfer_transaction.local_datetime) unless transfer_transaction.nil?
    end

    unless transfer_transaction.nil?
      deleted_transactions.push(transfer_transaction.id)
      transfer_transaction.children.destroy_all
      transfer_transaction.destroy
    end

    deleted_transactions.push(main_transaction.id)
    main_transaction.children.destroy_all
    main_transaction.destroy

    return deleted_transactions;
  end

  def self.update(transaction, params, current_user, scheduled: false)
    if transaction.class == String || transaction.class == Integer
      transaction = current_user.transactions.find(transaction)
    end

    return if transaction.nil?

    transactions = UpdateTransaction.new(transaction, params, current_user, scheduled: scheduled).perform
    return transactions
  end

  def self.update_upcoming_occurrence(params, current_user)
    
    transactions = self.update(current_user.transactions.find(params[:id]), params, current_user)

    return transactions
  end

  def self.destroy(transaction)
    transfer_transaction = transaction.transfer_transaction

    transaction.children.destroy_all
    transfer_transaction.children.destroy_all unless transfer_transaction.nil?

    transaction.destroy
    transfer_transaction.destroy unless transfer_transaction.nil?
  end

  # takes a transaction and returns its main transaction (ie the parent and, if transfer, the outgoing one)
  def self.find_main_transaction(transaction)
    if transaction.class == Array
      transaction = transaction[0]
    end

    transaction = Transaction.find(transaction.parent_id) unless transaction.parent_id.nil?
    
    unless transaction.transfer_transaction_id.nil?
      transaction = transaction.transfer_transaction if transaction.direction == 1
    end

    return transaction
  end

  def self.cancel_upcoming_occurrence(transaction, schedule_id, schedule_period_id)
    # if the transaction already exists, it means that it was edited and is_cancelled can simply be set to true
    if !transaction.scheduled_transaction_id.nil? || !transaction.scheduled_date.nil?
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
    return transactions
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

  def self.get_details(transactions, active_account)
    transaction_amounts_all = []
    account_ids_all = []
    transactions_parent = []
    account_names = []
    date = nil
    update_day_total = false
    total_amount = 0

    transactions.each do |t|

      amount = get_account_currency_amount(t, active_account)
      amount ||= 0
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

  def self.create(params, current_user, save: true, scheduled: false)
    transactions = CreateFromForm.new(params, current_user, scheduled: scheduled).perform
    return transactions unless save

    transactions = SaveTransactions.new(transactions, current_user).perform

    timezone = transactions[0].timezone if transactions.length > 0

    if timezone != current_user.timezone
      current_user.timezone = timezone
      current_user.save
    end

    transaction = self.find_main_transaction(transactions)

    update_account_balance = true
    unless transaction.transfer_transaction.nil?
      update_account_balance = false if transaction.account.id == transaction.transfer_transaction.account.id
    end

    if update_account_balance
      Account.add(current_user, transaction.account, transaction.account_currency_amount, transaction.local_datetime)
      Account.add(current_user, transaction.transfer_transaction.account, transaction.transfer_transaction.account_currency_amount, transaction.transfer_transaction.local_datetime) unless transaction.transfer_transaction.nil?
    end

    return transaction
  end

  def self.create_from_schedule(transaction, schedule, scheduled_transaction_id)
    transactions = CreateScheduledTransactions.new(transaction, schedule.user, scheduled_transaction_id, schedule, false, schedule.timezone).perform
    return transactions
  end

  def self.join_to_schedule(transaction, schedule)
    main_transaction = self.find_main_transaction(transaction)
    main_transaction.schedules << schedule
    return main_transaction
  end

  def self.approve_transaction(transaction, params)
    transaction.description = params[:description]
    transaction.amount = convert_float_to_i_amount(params[:amount], transaction.currency)
    params[:account_currency_amount].nil? ? transaction.account_currency_amount = convert_float_to_i_amount(params[:amount], transaction.currency) : transaction.account_currency_amount = convert_float_to_i_amount(params[:account_currency_amount], transaction.account.currency)
    params[:user_currency_amount].nil? ? transaction.user_currency_amount = convert_float_to_i_amount(params[:amount], transaction.currency) : transaction.user_currency_amount = convert_float_to_i_amount(params[:user_currency_amount], transaction.user.currency)

    transaction.is_queued = false
    transaction.save!

    Account.add(transaction.user, transaction.account, transaction.account_currency_amount, transaction.local_datetime)
  end

  def self.convert_float_to_i_amount(amount, currency)
    currency = Money::Currency.new(currency) if currency.class == String

    amount = amount.to_f
    return (amount * currency.subunit_to_unit).round.to_i
  end

end
