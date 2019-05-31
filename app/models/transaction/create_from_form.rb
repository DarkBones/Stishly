class Transaction
  class CreateFromForm

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
      @reg = ".+\s+[\.,]*-?[0-9\.,]*$"
    end

    def perform
      base_transactions = get_base_transactions(@params)
      base_transactions = link_transferred_transactions(@params, base_transactions)
      transactions = process_base_transactions(base_transactions)

      return transactions
    end

private

    def get_base_transactions(params, transferred=false, ignore_transfer=false)
      transactions = []

      account = get_account(params, transferred)
      currency = get_currency(params)
      user_rate = get_user_rate(currency, @current_user)

      current_transaction = {
        direction: get_direction(params, transferred),
        description: params[:description],
        amount: get_total_amount(params, transferred),
        currency: currency,
        account: account,
        user_currency: @current_user.currency,
        account_rate: get_account_rate(params, account, currency, transferred),
        user_rate: user_rate,
        timezone: params[:timezone],
        category_id: params[:category_id],
        local_datetime: parse_datetime(params[:date], params[:time]),
        #schedule_id: params[:schedule_id],
        is_scheduled: !params[:schedule_id].nil?
      }
      transactions.push(current_transaction)


      if params[:multiple] == 'multiple'
        transactions_string = params[:transactions].split("\n")
        transactions_string.each do |t_name_amount|
          if /#{@reg}/.match(t_name_amount)
            name_amount = t_name_amount.split(' ')
            amount_string = name_amount[-1]

            amount = 0
            amount = amount_string.to_f if amount.respond_to? "to_f"

            description = name_amount[0..-2].join(' ')

            child_params = params.dup
            child_params[:multiple] = 'single'
            child_params[:description] = description
            child_params[:amount] = amount

            current_transaction[:children] ||= []
            current_transaction[:children].push(get_base_transactions(child_params, transferred, true)[0])
          end
        end
      end

      if params[:type] == 'transfer' && !ignore_transfer
        transactions += get_base_transactions(params, true) unless transferred
      end

      return transactions

    end

    def link_transferred_transactions(params, base_transactions)
      return base_transactions unless params[:type] == 'transfer'

      idxs = []
      base_transactions.each_with_index do |bt, idx|
        idxs.push(idx) if bt[:parent_id].nil?
      end

      if idxs.length == 2
        base_transactions[idxs[0]][:transfer_transaction_id] = idxs[1]
        base_transactions[idxs[1]][:transfer_transaction_id] = idxs[0]

        base_transactions[idxs[0]][:transfer_account_id] = base_transactions[idxs[0]][:account].id
        base_transactions[idxs[1]][:transfer_account_id] = base_transactions[idxs[1]][:account].id
      end

      return base_transactions
    end

    # returns the rate between transaction currency and account currency
    def get_account_rate(params, account, currency, transferred)
      if params[:type] == 'transfer'
        return 1 unless transferred
        return params[:rate_from_to]
      end

      return 1 if account.currency == currency

      return params[:rate]
    end

    # returns the rate between transaction currency and user currency
    def get_user_rate(currency, current_user)
      user_currency = User.get_currency(current_user)

      return 1 if user_currency.iso_code == currency

      return CurrencyRate.get_rate(currency, user_currency.iso_code)
    end

    # returns the account object
    def get_account(params, transferred=false)
      return Account.get_from_name(params[:account], @current_user) unless params[:type] == 'transfer'

      if transferred
        return Account.get_from_name(params[:to_account], @current_user)
      else
        return Account.get_from_name(params[:from_account], @current_user)
      end
    end

    # returns the currency iso code
    def get_currency(params)
      return params[:currency] unless params[:type] == 'transfer'

      return Account.get_from_name(params[:from_account], @current_user).currency
    end

    # returns the total transaction amount in float
    def get_total_amount(params, transferred)
      total = 0

      if params[:multiple] == 'single'
        total = params[:amount].to_f
        return total * get_direction(params, transferred)
      end

      unless params[:transactions].nil?
        transactions = params[:transactions].split("\n")
        transactions.each do |t_name_amount|
          if /#{@reg}/.match(t_name_amount)
            amount = t_name_amount.split(' ')[-1]
            total += amount.to_f if amount.respond_to? "to_f"
          end
        end
      end

      return total * get_direction(params, transferred)
    end

    def get_direction(params, transferred)
      direction = 1
      if params[:type] == 'expense'
        direction = -1
      elsif params[:type] == 'transfer' && !transferred
        direction = -1
      end

      return direction
    end

    def process_base_transactions(base_transactions)
      transactions = []
      base_transactions.each do |bt|
        transaction = base_transaction_to_transaction(bt)

        unless bt[:children].nil?
          transaction[:children] = []
          bt[:children].each do |ct|
            transaction[:children].push(base_transaction_to_transaction(ct))
          end
        end

        transactions.push(transaction)
      end

      return transactions
    end

    # returns a transaction object from a base transaction
    def base_transaction_to_transaction(bt)
      transaction = {
        amount: amount_float_int(bt[:amount], bt[:currency]),
        direction: bt[:direction],
        description: bt[:description],
        account_id: bt[:account].id,
        timezone: bt[:timezone],
        currency: bt[:currency],
        account_currency_amount: amount_float_int((bt[:amount].to_f * bt[:account_rate].to_f), bt[:account].currency),
        category_id: bt[:category_id],
        local_datetime: bt[:local_datetime],
        transfer_account_id: bt[:transfer_account_id],
        user_currency_amount: amount_float_int((bt[:amount].to_f * bt[:user_rate].to_f), @current_user.currency),
        transfer_transaction_id: bt[:transfer_transaction_id],
        schedule_id: bt[:schedule_id],
        is_scheduled: bt[:is_scheduled]
      }
    end

    def parse_datetime(date, time)
      return if date.nil?

      months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

      date_arr = date.split('-')
      
      day = date_arr[0]
      month = months.index(date_arr[1].downcase)
      if month < 10
        month = '0' + month.to_s
      else
        month = month.to_s
      end

      month = date_arr[1]

      year = date_arr[2]

      time_arr = time.split(':')
      hours = time_arr[0]
      minutes = time_arr[1]
      seconds = Time.now.strftime('%S')

      return year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds
    end

    # convers a float amount to an integer amount (1 EUR = 100 EUR cents)
    def amount_float_int(amount, currency_code)
      currency = Money::Currency.new(currency_code)

      return (amount * currency.subunit_to_unit).round.to_i
    end

  end
end