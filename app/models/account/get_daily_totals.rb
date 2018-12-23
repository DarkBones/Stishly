class Account

  class GetDailyTotals

    def initialize(account_id, transactions, current_user)
      @current_user = current_user
      @account_id = account_id
      @transactions = transactions
    end

    def perform
      days = {}
      @transactions.each do |t|
        day = t.local_datetime.to_date
        if !days.keys.include? day
          if @account_id == 0
            days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?)", day).sum(:account_currency_amount)
          else
            days[day] = @current_user.transactions.where("DATE(transactions.local_datetime) = DATE(?) AND account_id = ?", day, @account_id).sum(:account_currency_amount)
          end
        end
      end

      return days
    end

  end

end