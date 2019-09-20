class Transaction
  class CreateFromForm
    include TimezoneMethods

    def initialize(params, current_user, scheduled: false)
      @params = params
      @current_user = current_user
      @reg = ".+\s+[\.,]*-?[0-9\.,]*$"
      @scheduled = scheduled
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
      queue_scheduled = 0
      queue_scheduled = params[:schedule_type].to_i unless params[:schedule_type].nil?
      local_datetime = parse_datetime(params[:date], params[:time])
      is_scheduled = get_is_scheduled(params, params[:timezone], local_datetime)
      timezone = get_timezone
      category_id = 0
      category_id = @current_user.categories.friendly.find(params[:category_id]).id if params[:category_id].length > 2

      schedule = @current_user.schedules.friendly.find(params[:schedule_id]) unless params[:schedule_id].nil?
      schedule_id = schedule.id unless schedule.nil?

      current_transaction = {
        direction: get_direction(params, transferred),
        description: params[:description],
        amount: get_total_amount(params, transferred),
        currency: currency,
        account: account,
        user_currency: @current_user.currency,
        account_rate: get_account_rate(params, account, currency, transferred),
        user_rate: user_rate,
        timezone: validate_timezone(timezone),
        category_id: category_id,
        local_datetime: local_datetime,
        schedule_id: schedule_id,
        schedule_period_id: params[:schedule_period_id],
        is_scheduled: is_scheduled,
        scheduled_transaction_id: params[:scheduled_transaction_id],
        queue_scheduled: queue_scheduled,
        scheduled_date: get_scheduled_date(is_scheduled, timezone, local_datetime)
      }

      transactions.push(current_transaction)


      if params[:multiple] == 'multiple'
        transactions_string = params[:transactions].split(/\r?\n/)
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

    def get_timezone
      return @params[:timezone] unless @params[:timezone].nil?

      unless @params[:schedule_id].nil?
        return @current_user.schedules.find(@params[:schedule_id]).timezone if @params[:schedule_id].to_i > 0
      end
      return @current_user.timezone
    end

    def get_scheduled_date(is_scheduled, timezone, local_datetime)
      return unless is_scheduled
      return if local_datetime.nil?
      #return unless @params[:schedule_id].nil? || @params[:schedule_id] == 0

      tz = TZInfo::Timezone.get(timezone)
      date_utc = tz.local_to_utc(local_datetime.to_datetime).to_date

      return date_utc
    end

    def get_is_scheduled(params, timezone, local_datetime)
      return true unless params[:schedule_id].nil?

      tz = TZInfo::Timezone.get(timezone)
      date_utc = tz.local_to_utc(local_datetime.to_datetime).to_date

      return Time.now.utc < date_utc

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
        transactions = params[:transactions].split(/\r?\n/)
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
      bt[:transfer_transaction_id].nil? ? category_id = bt[:category_id] : 0
      transaction = {
        amount: amount_float_int(bt[:amount], bt[:currency]),
        direction: bt[:direction],
        description: bt[:description],
        account_id: bt[:account].id,
        timezone: bt[:timezone],
        currency: bt[:currency],
        account_currency_amount: get_account_currency_amount(bt),
        category_id: category_id,
        local_datetime: bt[:local_datetime],
        transfer_account_id: bt[:transfer_account_id],
        user_currency_amount: get_user_currency_amount(bt),
        transfer_transaction_id: bt[:transfer_transaction_id],
        schedule_id: bt[:schedule_id],
        is_scheduled: bt[:is_scheduled],
        queue_scheduled: bt[:queue_scheduled],
        schedule_period_id: bt[:schedule_period_id],
        scheduled_transaction_id: bt[:scheduled_transaction_id],
        scheduled_date: bt[:scheduled_date]
      }
    end

    def get_account_currency_amount(bt)
      return if @scheduled
      return amount_float_int((bt[:amount].to_f * bt[:account_rate].to_f), bt[:account].currency)
    end

    def get_user_currency_amount(bt)
      return if @scheduled
      amount_float_int((bt[:amount].to_f * bt[:user_rate].to_f), @current_user.currency)
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
      seconds = Time.now.utc.strftime('%S')

      return year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds
    end

    # convers a float amount to an integer amount (1 EUR = 100 EUR cents)
    def amount_float_int(amount, currency_code)
      currency = Money::Currency.new(currency_code)

      return (amount * currency.subunit_to_unit).round.to_i
    end

  end
end