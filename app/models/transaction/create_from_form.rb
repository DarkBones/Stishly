class Transaction
  class CreateFromForm

    def initialize(params, current_user)
      @current_user = current_user
      @params = params[:transaction]
    end

    def perform
      base_transactions = get_base_transactions
      require 'yaml'
      

      transactions = process_base_transactions(base_transactions)

      puts ''
      puts transactions
      puts transactions.class.name
      puts transactions.to_yaml

      Account.create_from_list(transactions)
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

      base_transactions.each do |t|
        if type == 'transfer'
          transactions.push(transaction_object(t, from_account))
          transactions.push(transaction_object(t, to_account, true))
        else
          transactions.push(transaction_object(t, account))
        end
      end

      return transactions
    end

    def transaction_object(base_transaction, account, reverse_direction = false)
      direction = 1
      type = get_type

      if type != 'income'
        direction = -1
      end

      direction *= -1 if reverse_direction

      transaction = {
        user_id: @current_user.id,
        amount: convert_transaction_amount(base_transaction[:amount]) * direction,
        description: base_transaction[:description],
        account_id: account.id,
        timezone: @params[:timezone],
        local_datetime: get_local_datetime(Time.now),
        currency: @params[:currency],
        account_currency_amount: convert_transaction_amount(get_account_currency_amount(base_transaction[:amount], account)) * direction,
        category_id: @params[:category_id].to_i,
        is_child: base_transaction[:is_child]
      }

      return transaction
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
      require 'yaml'
      puts @params.to_yaml

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

      reg = ".+\s+[\.,]*[0-9\.]+$"

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
  
    def get_transactions_OLD(parent_id = nil, transactions = [], description = nil, type = nil, accounts = nil, currency = nil, category_id = nil, multiple_transactions = nil)
      require 'yaml'
      puts @params.to_yaml

      description ||= @params[:description]
      type ||= @params[:type].downcase

      if accounts == nil
        if type == 'transfer'
          accounts = []
          accounts.push(@current_user.accounts.where(name: params[:from_account]).take)
          accounts.push(@current_user.accounts.where(name: params[:to_account]).take)
        else
          accounts = [@current_user.accounts.where(name: params[:account]).take]
        end
      end

      currency ||= Money::Currency.new(@params[:currency])
      category_id ||= @params[:category_id]
      multiple_transactions ||= @params[:multiple_transactions].to_i

      if multiple_transactions == 1

      else
        amount = @params[:amount].to_f
      end
    end

  end
end