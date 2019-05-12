class Transaction
  class UpdateTransaction

    def initialize(transaction_id, params, current_user)
      @current_user = current_user
      @params = params
      @transaction = current_user.transactions.find(transaction_id)
    end

    def perform
      return if @transaction.nil?

      transaction = create_transaction
    end

private

    def create_transaction
      new_transactions = make_transactions(@params)

      # find transfer ids
      transfer_transactions = []
      new_transactions.each do ZtZ
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

      return new_transactions

    end

    def make_transactions(params, parent_id=nil, transferred=false)
      return [] if @params[:is_child] && parent_id.nil?

      transactions = []

      transaction = @current_user.transactions.new

      account = Account.get_from_name(params[:account], @current_user)
      from_account = Account.get_from_name(params[:from_account], @current_user)
      to_account = Account.get_from_name(params[:to_account], @current_user)

      transaction.account_id = get_account_id(params[:type], account, from_account, to_account, transferred)
      transaction.direction = get_direction(params[:type], params[:amount].to_f, transferred)
      transaction.amount = get_amount(params[:currency], params[:amount].to_f, params[:transactions], params[:multiple]) * transaction.direction
      transaction.description = params[:description]
      transaction.currency = get_currency(params[:type], params[:currency], from_account)
      transaction.category_id = params[:category_id]
      transaction.transfer_account_id = get_transfer_account_id(params[:type], from_account, to_account, transferred)
      transaction.is_scheduled = @transaction.is_scheduled
      transaction.parent_id = parent_id
      # TODO: Figure out how to set the date and time (scheduled transacitons won't use this, but regular transaction will)

      transaction.save
      parent_id = transaction.id
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

    def get_amount(current, amount, transactions, multiple)
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
