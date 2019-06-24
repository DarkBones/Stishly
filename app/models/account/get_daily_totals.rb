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

=begin
      @transactions.each do |t|
        next if t.is_scheduled == true

        day = t.local_datetime.to_date

        if @account_id != 0
          days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND account_id = ? AND is_scheduled = 0", day, @account_id).sum(:account_currency_amount) unless days.keys.include? day
        else
          days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND parent_id IS NULL AND is_scheduled = 0", day).sum(:user_currency_amount) unless days.keys.include? day
        end
      end
=end
      return days
    end

    # takes a transaction, and returns the amount in the user's default currency
    def get_user_amount(transaction)
      t_currency = Money::Currency.new(transaction.currency)
      a_currency = Money::Currency.new(transaction.account.currency)

      # return the amount if the currencies are the same
      return transaction.amount if t_currency.iso_code == @user_currency.iso_code

      # return the account currency amount if the account currency is the same as the user currency
      return transaction.account_currency_amount if a_currency == @user_currency.iso_code

      rate = CurrencyRate.get_rate(t_currency.iso_code, @user_currency.iso_code)

      return (transaction.amount * rate)
    end

  end

end