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

        transfer_transactions[0].save unless transfer_transactions[0].account.is_disabled
        transfer_transactions[1].save unless transfer_transactions[1].account.is_disabled
      end

      link_schedule(transactions, schedule)

      main_transaction = Transaction.find_main_transaction(transactions[0])
      main_transaction.is_main = true
      main_transaction.save if main_transaction.account.is_disabled == false

      # if the user has too many transactions, delete the oldest one(s)
      handle_retention(@current_user)

      return transactions

    end

private

    def handle_retention(user)
      max_transactions = APP_CONFIG['plans'][user.subscription]['max_transactions']
      return if max_transactions < 0

      main_transactions = user.transactions.where("is_main = true").order(:local_datetime)

      if main_transactions.length > max_transactions
        to_delete = main_transactions.length - max_transactions
        deleted = 0
        main_transactions.each do |t|
          Transaction.delete(t, user)
          deleted += 1

          break if deleted >= to_delete
        end
      end

    end

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

      t.save! unless t.account.is_disabled

      return t
    end

  end
end