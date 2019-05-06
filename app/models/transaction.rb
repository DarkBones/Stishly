# == Schema Information
#
# Table name: transactions
#
#  id                      :bigint(8)        not null, primary key
#  user_id                 :bigint(8)
#  amount                  :integer
#  direction               :integer
#  description             :string(100)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  account_id              :integer
#  timezone                :string(255)      not null
#  currency                :string(255)
#  account_currency_amount :integer
#  category_id             :bigint(8)
#  parent_id               :bigint(8)
#  exclude_from_all        :boolean          default(FALSE)
#  local_datetime          :datetime         not null
#  transfer_account_id     :bigint(8)
#  user_currency_amount    :integer          not null
#  transfer_transaction_id :integer
#

class Transaction < ApplicationRecord
  belongs_to :account
  has_one :user, through: :account
  belongs_to :category, optional: true
  has_one :parent, :class_name => 'Transaction'
  has_many :children, :class_name => 'Transaction', :foreign_key => 'parent_id'

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc', include_children: 1 },
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
      :sorted_by
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

  def self.search(current_user, query)
    return Search.new(current_user, query).perform
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

    # find transfer_transaction_id for transfer transactions
    transfer_transactions = []
    result.each do |t|
      if t.parent_id.nil?
        unless t.transfer_account_id.nil?
          transfer_transactions.push(t)
        end
      end
    end

    if transfer_transactions.length == 2
      t1 = transfer_transactions[0]
      t2 = transfer_transactions[1]

      t1.transfer_transaction_id = t2.id
      t2.transfer_transaction_id = t1.id

      t1.save
      t2.save
    end
    
    return result
  end

  def self.get_details(transactions, params, current_user)
    transaction_amounts_all = []
    account_ids_all = []
    transactions_parent = []
    account_names = []
    date = nil
    update_day_total = false
    total_amount = 0

    transactions.each do |t|
      amount = get_user_currency_amount(t, params[:active_account], current_user)
      date = t.local_datetime.to_s.split[0]

      if params[:active_account].nil? || params[:active_account] == t.account.name
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

  def self.get_user_currency_amount(transaction, account_name, current_user)
    user_currency = User.get_currency(current_user)

    amount = transaction.account_currency_amount
    if transaction.currency != user_currency.iso_code && account_name == ''
      amount = CurrencyRate.convert(amount, Money::Currency.new(transaction.currency), user_currency)
    end

    return amount
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
    t.user_currency_amount = transaction[:user_currency_amount]
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
