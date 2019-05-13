class Transaction

  class CreateScheduledTransactions

    def initialize(transaction, current_user)
      @transaction = transaction
      @current_user = current_user
    end

    def perform
      return make_transactions(@transaction)
    end

private

    def make_transactions(transaction, transfer_transaction=nil, parent_id=nil, transactions=[])
      transaction = @current_user.transactions.find(transfer_transaction) unless transfer_transaction.nil?

      t = @current_user.transactions.find(transaction.id)
      t ||= @current_user.transactions.new
      t.amount = transaction.amount
      t.direction = transaction.direction
      t.description = transaction.description
      t.account_id = transaction.account_id
      t.currency = transaction.currency
      t.category_id = transaction.category_id
      t.parent_id = parent_id
      t.transfer_account_id = transaction.transfer_account_id
      t.is_scheduled = true

      t.save

      transactions.push(t)

      unless transaction.transfer_transaction_id.nil?
        transactions = make_transactions(transaction, transaction.transfer_transaction_id, nil, transactions) if transfer_transaction.nil?
      end

      if transaction.children.length > 0
        transaction.children.each do |ct|
          transactions = make_transactions(ct, nil, t.id, transactions)
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

end