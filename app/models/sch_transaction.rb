# == Schema Information
#
# Table name: s_transactions
#
#  id                  :bigint(8)        not null, primary key
#  user_id             :bigint(8)
#  amount              :integer
#  direction           :integer
#  description         :string(255)
#  account_id          :bigint(8)
#  currency            :string(255)
#  category_id         :bigint(8)
#  parent_id           :bigint(8)
#  transfer_account_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class SchTransaction < ApplicationRecord
  has_and_belongs_to_many :schedules
  belongs_to :account
  has_one :user, through: :account
  belongs_to :category, optional: true
  has_one :parent, :class_name => 'ScheduledTransaction'
  has_many :children, :class_name => 'SchTransaction', :foreign_key => 'parent_id'

  attr_accessor :type, :from_account, :to_account, :multiple

  def self.create_from_transaction(transaction, current_user, transfer_transaction=nil, parent_id=nil, transactions=[])
    unless transfer_transaction.nil?
      transaction = current_user.transactions.where(id: transfer_transaction).take
    end

    t = current_user.sch_transactions.where(original_transaction_id: transaction.id).take
    t ||= current_user.sch_transactions.new
    t.amount = transaction.amount
    t.direction = transaction.direction
    t.description = transaction.description
    t.account_id = transaction.account_id
    t.currency = transaction.currency
    t.category_id = transaction.category_id
    t.parent_id = parent_id
    t.transfer_account_id = transaction.transfer_account_id
    t.original_transaction_id = transaction.id
    #t.transfer_transaction_id = transaction.transfer_transaction_id

    t.save

    transactions.push(t)

    unless transaction.transfer_transaction_id.nil?
      transactions = self.create_from_transaction(transaction, current_user, transaction.transfer_transaction_id, nil, transactions) if transfer_transaction.nil?
    end

    if transaction.children.length > 0
      transaction.children.each do |ct|
        transactions = self.create_from_transaction(ct, current_user, nil, t.id, transactions)
      end
    end

    # find transfer_transaction_id
    transfer_transactions = []
    transactions.each do |trx|
      transfer_transactions.push(trx) if trx.parent_id.nil?
    end

    if transfer_transactions.length == 2
      transfer_transactions[0].transfer_transaction_id = transfer_transactions[1].id
      transfer_transactions[1].transfer_transaction_id = transfer_transactions[0].id

      transfer_transactions[0].save
      transfer_transactions[1].save
    end

    return transactions

  end

  def self.update(params, current_user)
    sch_transaction = current_user.sch_transactions.find(params[:id])
    self.create_transaction(sch_transaction, params, current_user) unless sch_transaction.nil?
    self.destroy_original(sch_transaction, current_user)
  end

private

  def self.create_transaction(transaction, params, current_user)
    transaction = current_user.sch_transactions.find(params[:id])
    new_transactions = self.make_transactions(params, current_user, transaction.original_transaction_id)

    # find transfer ids
    transfer_transactions = []
    new_transactions.each do |t|
      transfer_transactions.push(t) if t.parent_id.nil?
    end

    if transfer_transactions.length == 2
      transfer_transactions[0].transfer_transaction_id = transfer_transactions[1].id
      transfer_transactions[1].transfer_transaction_id = transfer_transactions[0].id

      transfer_transactions[0].save
      transfer_transactions[1].save
    end

    new_transactions.each do |nt|
      transaction.schedules.each do |sc|
        nt.schedules << sc
      end
    end

  end

  def self.destroy_original(transaction, current_user)
    transfer_transaction = current_user.sch_transactions.find(transaction.transfer_transaction_id) unless transaction.transfer_transaction_id.nil?

    transaction.children.destroy_all
    transfer_transaction.children.destroy_all unless transfer_transaction.nil?

    transaction.destroy
    transfer_transaction.destroy unless transfer_transaction.nil?
  end

  def self.make_transactions(params, current_user, original_transaction_id=nil, parent_id=nil, transferred=false)
    return [] if params[:is_child] && parent_id.nil?

    transactions = []

    transaction = current_user.sch_transactions.new

    account = Account.get_from_name(params[:account], current_user)
    from_account = Account.get_from_name(params[:from_account], current_user)
    to_account = Account.get_from_name(params[:to_account], current_user)

    transaction.account_id = self.get_account_id(params[:type], account, from_account, to_account, transferred)
    transaction.direction = self.get_direction(params[:type], params[:amount].to_f, transferred)
    transaction.amount = self.get_amount(params[:currency], params[:amount].to_f, params[:transactions], params[:multiple]) * transaction.direction
    transaction.description = params[:description]
    transaction.currency = self.get_currency(params[:type], params[:currency], from_account, to_account, transferred)
    transaction.category_id = params[:category_id]
    transaction.transfer_account_id = self.get_transfer_account_id(params[:type], from_account, to_account, transferred)
    transaction.original_transaction_id = original_transaction_id unless parent_id.nil?

    transaction.parent_id = parent_id

    transaction.save
    parent_id = transaction.id

    if params[:type] == "transfer" && !transferred
      transactions += make_transactions(params, current_user, original_transaction_id, nil, true)
    end

    if params[:multiple] == "multiple"
      transactions_str = params[:transactions].split("\n")
      transactions_str.each do |ct|
        ct.strip!
        ct = ct.split
        description = ""
        amount = 0.0
        if ct[-1].respond_to?("to_f")
          description = ct[0..-2].join(" ")
          amount = ct[-1].to_f
        else
          description = ct.join(" ")
        end

        child_params = params.dup

        child_params[:description] = description
        child_params[:amount] = amount
        child_params[:parent_id] = parent_id
        child_params[:multiple] = "single"
        child_params[:is_child] = true

        transactions += make_transactions(child_params, current_user, original_transaction_id, parent_id, transferred)
      end
    end

    transactions.push(transaction)
    return transactions
  end

  def self.get_transfer_account_id(type, from_account, to_account, transferred)
    return nil if type != "transfer"
    return from_account.id if transferred
    return to_account.id
  end

  def self.get_currency(type, currency, from_account, to_account, transferred)
    if type != "transfer"
      return currency
    else
      return from_account.currency
    end
  end

  def self.get_amount(currency, amount, transactions, multiple)
    currency = Money::Currency.new(currency)
    if multiple == "multiple"
      return self.get_multiple_total(transactions) * currency.subunit_to_unit
    else
      return amount * currency.subunit_to_unit
    end
  end

  def self.get_multiple_total(transactions)
    total = 0
    transactions = transactions.split("\n")
    transactions.each do |t|
      t.strip!
      amount_str = t.split[-1]
      if amount_str.respond_to?("to_f")
        total += amount_str.to_f
      end
    end

    return total
  end

  def self.get_direction(type, amount, transferred)
    direction = -1
    direction = 1 if type == "income"
    direction *= -1 if transferred

    amount *= direction

    if amount >= 0
      return 1
    else
      return -1
    end
  end

  def self.get_account_id(type, account, from_account, to_account, transferred)
    case type
    when "transfer"
      return from_account.id unless transferred
      return to_account.id
    else
      return account.id
    end
  end

end
