class Transaction
  class SaveTransactions

    def initialize(transactions, current_user, link_to_schedule=true)
      @transactions = transactions
      @current_user = current_user
      @link_to_schedule = link_to_schedule
    end

    def perform
      transactions = []
      transfer_transactions = []

      schedule = nil
      @transactions.each do |t|
        transfer_account_id = nil
        parent_id = nil

        schedule ||= t[:schedule_id]

        unless t[:transfer_transaction_id].nil?
          transfer_account_id = @transactions[t[:transfer_transaction_id]][:transfer_account_id]
        end

        transaction = save_transaction(t, @current_user, transfer_account_id, parent_id)

        unless t[:transfer_transaction_id].nil?
          transfer_transactions.push(transaction)
        end

        transactions.push(transaction)

        unless t[:children].nil?
          parent_id = transaction.id

          t[:children].each do |ct|
            transaction = save_transaction(ct, @current_user, transfer_account_id, parent_id)
            transactions.push(transaction)
          end
        end

      end

      if transfer_transactions.length == 2
        transfer_transactions[0].transfer_transaction_id = transfer_transactions[1].id
        transfer_transactions[1].transfer_transaction_id = transfer_transactions[0].id

        transfer_transactions[0].save
        transfer_transactions[1].save
      end

      link_schedule(transactions, schedule)

      return transactions

    end

private

    def link_schedule(transactions, schedule)
      return if schedule.nil? || !@link_to_schedule

      schedule = @current_user.schedules.find(schedule.to_i)

      return if schedule.nil?

      main_transaction = Transaction.find_main_transaction(transactions)
      Transaction.join_to_schedule(main_transaction, schedule)
    end

    def save_transaction(transaction, current_user, transfer_account_id, parent_id)
      t = current_user.transactions.new

      t.amount = transaction[:amount]
      t.user_id = current_user.id
      t.direction = transaction[:direction]
      t.description = transaction[:description]
      t.account_id = transaction[:account_id]
      t.timezone = transaction[:timezone]
      t.currency = transaction[:currency]
      t.account_currency_amount = transaction[:account_currency_amount]
      t.category_id = transaction[:category_id]
      t.parent_id = parent_id
      t.transfer_account_id = transfer_account_id
      t.user_currency_amount = transaction[:user_currency_amount]
      t.local_datetime = transaction[:local_datetime]
      t.is_scheduled = transaction[:is_scheduled]
      t.queue_scheduled = transaction[:queue_scheduled]
      t.schedule_id = transaction[:schedule_id]
      t.schedule_period_id = transaction[:schedule_period_id]
      t.scheduled_transaction_id = transaction[:scheduled_transaction_id]
      t.scheduled_date = transaction[:scheduled_date]

      t.save!

      return t
    end

  end
end