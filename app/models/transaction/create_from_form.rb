class Transaction
  class CreateFromForm

    def initialize(params, current_user)
      @current_user = current_user
      @params = params[:transaction]
    end

    def perform
      base_transactions = get_base_transactions

      transactions = process_base_transactions(base_transactions)

      Transaction.create_from_list(@current_user, transactions)
    end

private
    
    def process_base_transactions(base_transactions)
      type = get_type

      transactions = []

      if type == 'transfer'
        from_account = @current_user.accounts.where(name: @params[:from_account]).take
        to_account = @current_user.accounts.where(name: @params[:to_account]).take
      else
        account = @current_user.accounts.where(name: @params[:account]).take
      end

      parent_id = nil
      parent_id_from = nil
      parent_id_to = nil
      if @params[:multiple_transactions] == '1'
        base_transactions.each do |t|
          if t[:is_child] == false
            if type == 'transfer'
              parent_id_from = Transaction.create_transaction(@current_user, transaction_object(t, from_account)).id
              parent_id_to = Transaction.create_transaction(@current_user, transaction_object(t, to_account, true)).id
            else
              parent_id = Transaction.create_transaction(@current_user, transaction_object(t, account)).id
            end
          end
        end
      end

      base_transactions.each do |t|
        if (t[:is_child] == true && @params[:multiple_transactions] == '1') || (@params[:multiple_transactions] == '0')
          if type == 'transfer'
            transactions.push(transaction_object(t, from_account, false, parent_id_from))
            transactions.push(transaction_object(t, to_account, true, parent_id_to))
          else
            transactions.push(transaction_object(t, account, false, parent_id))
          end
        end
      end

      return transactions
    end

    def transaction_object(base_transaction, account, reverse_direction = false, parent_id = nil)
      direction = 1
      type = get_type

      if type != 'income'
        direction = -1
      end

      direction *= -1 if reverse_direction

      if type == 'transfer'
        exclude_from_all = 1
      else
        exclude_from_all = 0
      end

      transaction = {
        user_id: @current_user.id,
        amount: convert_transaction_amount(base_transaction[:amount]) * direction,
        description: base_transaction[:description],
        account_id: account.id,
        timezone: @params[:timezone],
        #local_datetime: get_local_datetime(Time.now),
        local_datetime: parse_datetime,
        currency: @params[:currency],
        account_currency_amount: get_account_currency_amount(convert_transaction_amount(base_transaction[:amount]), account) * direction,
        category_id: @params[:category_id].to_i,
        is_child: base_transaction[:is_child],
        exclude_from_all: exclude_from_all,
        parent_id: parent_id
      }

      return transaction
    end

    def parse_datetime
      date_arr = @params[:date].split('-')
      
      day = date_arr[0]
      month = date_arr[1]
      year = date_arr[2]

      time_arr = @params[:time].split(':')
      hours = time_arr[0]
      minutes = time_arr[1]

      return year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + "00"
    end

    def get_account_currency_amount(amount, account)
      transaction_currency = Money::Currency.new(@params[:currency])
      account_currency = Money::Currency.new(account.currency)

      if transaction_currency.iso_code != account_currency.iso_code
        return CurrencyRate.convert(amount, transaction_currency, account_currency)
      else
        return amount
      end
    end

    def get_local_datetime(time)
      tz = TZInfo::Timezone.get(@params[:timezone])
      return tz.utc_to_local(time)
    end

    def convert_transaction_amount(amount)
      currency = Money::Currency.new(@params[:currency])

      return (amount * currency.subunit_to_unit).round.to_i
    end

    def get_type
      return @params[:type].downcase
    end

    def get_base_transactions
      transactions = []

      if @params[:multiple_transactions] == '1'
        multiple_transactions = parse_multiple_transactions
        child_transactions = multiple_transactions[:transactions]
        total_amount = multiple_transactions[:total_amount]

        parent_transaction = base_transaction_object(@params[:description], total_amount, false)
        transactions.push(parent_transaction)
        child_transactions.each do |child|
          transactions.push(child)
        end
      else
        transaction = base_transaction_object(@params[:description], parse_amount(@params[:amount]), false)
        transactions.push(transaction)
      end

      return transactions
    end

    def parse_multiple_transactions
      transactions = []
      total_amount = 0

      reg = ".+\s+[\.,]*[0-9\.,]+$"

      transaction_text = @params[:transactions]
      transaction_list = transaction_text.split("\n")

      transaction_list.each do |t_name_amount|
        t_name_amount.strip!

        if /#{reg}/.match(t_name_amount)
          name_amount = t_name_amount.split

          description = name_amount[0..-2].join(' ')

          amount = parse_amount(name_amount[-1])

          total_amount += amount

          transaction = base_transaction_object(description, amount, true)

          transactions.push(transaction)
        end

      end

      return {
        transactions: transactions,
        total_amount: total_amount
      }

    end

    def base_transaction_object(description, amount, is_child)
      return {
        description: description,
        amount: amount,
        is_child: is_child
      }
    end

    def parse_amount(amount)
      amount = amount.sub(',', '.')
      amount = amount.to_f
      return amount
    end

  end
end