class Transaction
  class UpdateTransaction

    def initialize(transaction_id, params, current_user)
      @current_user = current_user
      @params = params
      @transaction = current_user.transactions.find(transaction_id)
    end

    def perform
      return if @transaction.nil?

      transactions = create_transaction
      update_scheduled_transaction_ids(transactions)

      destroy_original(@transaction, @current_user)

      return transactions
    end

private

    def update_scheduled_transaction_ids(transactions)
      transactions.each do |t|
        if t.parent_id.nil?
          if t.transfer_transaction_id.nil? || (!t.transfer_transaction_id.nil? && t.direction == -1)
            scheduled_transactions = @current_user.transactions.where(scheduled_transaction_id: @transaction.id)
            scheduled_transactions.each do |st|
              st.scheduled_transaction_id = t.id
              st.save
            end
            return
          end
        end
      end
    end

    def destroy_original(transaction, current_user)
      transfer_transaction = current_user.sch_transactions.find(transaction.transfer_transaction_id) unless transaction.transfer_transaction_id.nil?

      transaction.children.destroy_all
      transfer_transaction.children.destroy_all unless transfer_transaction.nil?

      transaction.destroy
      transfer_transaction.destroy unless transfer_transaction.nil?
    end

    def create_transaction
      new_transactions = make_transactions(@params)

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
        @transaction.schedules.each do |sc|
          if nt.parent_id.nil?
            if nt.transfer_transaction_id.nil? || (!nt.transfer_transaction_id.nil? && nt.direction == -1)
              nt.schedules << sc
            end
          end
        end
      end

      return new_transactions

    end

    def make_transactions(params, parent_id=nil, transferred=false)
      return [] if @params[:is_child] && parent_id.nil?

      transactions = []

      transaction = @current_user.transactions.new

      account = Account.get_from_name(params[:account], @current_user)
      from_account = Account.get_from_name(params[:from_account], @current_user)
      to_account = Account.get_from_name(params[:to_account], @current_user)

      transaction.user_id = @current_user.id
      transaction.account_id = get_account_id(params[:type], account, from_account, to_account, transferred)
      transaction.direction = get_direction(params[:type], params[:amount].to_f, transferred)
      transaction.amount = get_amount(params[:currency], params[:amount].to_f, params[:transactions], params[:multiple]) * transaction.direction
      transaction.description = params[:description]
      transaction.currency = get_currency(params[:type], params[:currency], from_account)
      transaction.category_id = params[:category_id]
      transaction.transfer_account_id = get_transfer_account_id(params[:type], from_account, to_account, transferred)
      transaction.is_scheduled = @transaction.is_scheduled
      transaction.parent_id = parent_id
      transaction.local_datetime = get_local_datetime(params[:date], params[:time]) unless @transaction.is_scheduled
      transaction.timezone = @transaction.timezone
      transaction.account_currency_amount = get_account_currency_amount(params[:amount].to_f, transaction.account.currency, params[:currency], params[:rate].to_f) unless @transaction.is_scheduled
      transaction.user_currency_amount = get_user_currency_amount(params[:amount].to_f, params[:currency], @current_user.currency) unless @transaction.is_scheduled

      transaction.save
      parent_id = transaction.id

      if params[:type] == "transfer" && !transferred
        transactions += make_transactions(params, nil, true)
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

          transactions += make_transactions(child_params, parent_id, transferred)

        end
      end

      transactions.push(transaction)
      return transactions

    end

    def get_user_currency_amount(amount, currency_transaction, currency_user)
      currency_transaction = Money::Currency.new(currency_transaction)
      currency_user = Money::Currency.new(currency_user)

      amount *= currency_transaction.subunit_to_unit
      amount = CurrencyRate.convert(amount, currency_transaction, currency_user)
      return amount
    end

    def get_account_currency_amount(amount, currency_account, currency_transaction, rate)

      currency_account = Money::Currency.new(currency_account)
      currency_transaction = Money::Currency.new(currency_transaction)

      amount *= currency_transaction.subunit_to_unit
      amount = CurrencyRate.convert(amount, currency_transaction, currency_account, rate)

      return amount
    end

    def get_local_datetime(date_str, time_str)
      return if @transaction.is_scheduled || date_str.nil? || time_str.nil?

      # get the time in seconds if there is a local_datetime stored
      seconds = @transaction.local_datetime.strftime("%S")
      datetime_str = "#{date_str} #{time_str}:#{seconds}"

      return Date.parse(datetime_str)
    end

    def get_transfer_account_id(type, from_account, to_account, transferred)
      return nil if type != "transfer"
      return from_account.id if transferred
      return to_account.id
    end

    def get_currency(type, currency, from_account)
      if type != "transfer"
        return currency
      else
        return from_account.currency
      end
    end

    def get_amount(currency, amount, transactions, multiple)
      currency = Money::Currency.new(currency)
      if multiple == "multiple"
        return get_multiple_total(transactions) * currency.subunit_to_unit
      else
        return amount * currency.subunit_to_unit
      end
    end

    def get_multiple_total(transactions)
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

    def get_direction(type, amount, transferred)
      direction = -1
      direciton = 1 if type == "income"
      direction *= -1 if transferred

      amount *= direction

      if amount >= 0
        return 1
      else
        return -1
      end
    end

    def get_account_id(type, account, from_account, to_account, transferred)
      case type
      when "transfer"
        return from_account.id unless transferred
        return to_account.id
      else
        return account.id
      end
    end

  end
end
