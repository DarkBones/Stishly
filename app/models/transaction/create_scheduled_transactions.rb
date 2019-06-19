class Transaction

  class CreateScheduledTransactions

    def initialize(transaction, current_user, schedule=nil, is_scheduled=true, timezone=nil)
      @transaction = transaction
      @current_user = current_user
      @is_scheduled = is_scheduled
      @timezone = timezone
      @schedule = schedule
    end

    def perform
      transactions = make_transactions(@transaction)
      return transactions
    end

private

    def make_transactions(transaction, transfer_transaction=nil, parent_id=nil, transactions=[])
      schedule_id = nil
      unless @schedule.nil?
        schedule_id = @schedule.id
      end

      transaction = @current_user.transactions.find(transfer_transaction) unless transfer_transaction.nil?

      account = transaction.account
      is_queued = transaction.queue_scheduled
      is_queued ||= false
      
      t = t.dup unless t.nil?
      t ||= @current_user.transactions.new
      t.user_id = @current_user.id
      t.amount = transaction.amount
      t.direction = transaction.direction
      t.description = transaction.description
      t.account_id = account.id
      t.currency = transaction.currency
      t.category_id = transaction.category_id
      t.parent_id = parent_id
      t.transfer_account_id = transaction.transfer_account_id
      t.is_scheduled = @is_scheduled
      t.account_currency_amount = nil
      t.user_currency_amount = nil
      t.timezone = nil
      t.local_datetime = nil
      t.schedule_id = schedule_id
      t.queue_scheduled = transaction.queue_scheduled
      t.is_queued = is_queued

      unless @is_scheduled
        t.timezone = @schedule.timezone
        t.local_datetime = get_local_datetime
        t.account_currency_amount = get_currency_amount(transaction.amount, transaction.currency, account.currency)
        t.user_currency_amount = get_currency_amount(transaction.amount, transaction.currency, @current_user.currency)
      end

      t.save
      Account.add(t.user, t.account.id, t.account_currency_amount) if t.parent_id.nil? && t.is_queued == false
      Message.create_message(USER_MESSAGES['new_queued_transaction'], @current_user, true)

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

    def get_local_datetime
      tz = TZInfo::Timezone.get(@timezone)
      return tz.utc_to_local(Time.now.utc)
    end

    def get_currency_amount(amount, from, to)
      return CurrencyRate.convert(amount, from, to)
    end

  end

end