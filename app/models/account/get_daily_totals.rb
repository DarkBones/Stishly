class Account

  class GetDailyTotals

    def initialize(account_id, transactions, current_user)
      @current_user = current_user
      @account_id = account_id
      @transactions = transactions
      @user_currency = User.get_currency(current_user)
    end

    def perform
      days = {}

      @transactions.each do |t|
        day = t.local_datetime.to_date

        if @account_id != 0
          if !days.keys.include? day
            days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND account_id = ?", day, @account_id).sum(:account_currency_amount)
          end
        else
          t_currency = Money::Currency.new(t.currency)
          user_amount = 0

          if t_currency.iso_code == @user_currency.iso_code
            user_amount = t.amount
          else
            rate = CurrencyRate.get_rate(t_currency.iso_code, @user_currency.iso_code)
            user_amount = CurrencyRate.convert(t.amount, t_currency, @user_currency, rate)
          end

          if !days.keys.include? day
            days[day] = 0
          end

          days[day] += user_amount if t.transfer_account_id == nil
        end

      end

      return days
    end

    def perform_FUB
      days = {}

      @transactions.each do |t|
        day = t.local_datetime.to_date

        if @account_id != 0
          days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND account_id = ?", day, @account_id).sum(:account_currency_amount) if !days.keys.include? day
        else
          days[day] = 0 if !days.keys.include? day

          days[day] += get_user_amount(t) if t.transfer_account_id == nil
        end
      end

      return days
    end

    # takes a transaction, and returns the amount in the user's default currency
    def get_user_amount(transaction)
      t_currency = Money::Currency.new(transaction.currency)

      # return the amount if the currencies are the same
      return transaction.amount if t_currency.iso_code == @user_currency.iso_code

      rate = CurrencyRate.get_rate(t_currency.iso_code, @user_currency.iso_code)

      return (transaction.amount * rate) * @user_currency.subunit_to_unit
    end

=begin
    def perform_OLD
      days = {}

      @transactions.each do |t|
        day = t.local_datetime.to_date

        if @account_id != 0
          if !days.keys.include? day
            days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND account_id = ?", day, @account_id).sum(:account_currency_amount)
          end
        else
          t_currency = Money::Currency.new(t.currency)
          user_amount = 0

          if t_currency.iso_code == @user_currency.iso_code
            user_amount = t.amount
          else
            rate = CurrencyRate.get_rate(t_currency.iso_code, @user_currency.iso_code)
            user_amount = (t.amount * rate) * @user_currency.subunit_to_unit
          end

          if !days.keys.include? day
            days[day] = 0
          end

          days[day] += user_amount if t.transfer_account_id == nil
        end

      end

      return days
    end
=end

    def perform_OLD
      days = {}
      @transactions.each do |t|
        day = t.local_datetime.to_date

        if !days.keys.include? day
          if @account_id == 0
            days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL", day).sum(:account_currency_amount)

          else
            days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND account_id = ?", day, @account_id).sum(:account_currency_amount)
          end
        end
      end

      return days
    end

  end

end