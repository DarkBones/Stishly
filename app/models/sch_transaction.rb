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
end
