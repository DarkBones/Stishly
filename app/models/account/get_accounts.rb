class Account
  class GetAccounts

    def initialize(current_user)
      @accounts = current_user.accounts.order(:position)
      user_currency = User.get_currency(current_user).iso_code
      #@total_balance = @accounts.sum(:balance)
      @total_balance = 0
      @accounts.each do |a|
        account_currency = Account.get_currency(a.id, current_user)
        if user_currency != account_currency
          @total_balance += Concurrency.convert(a.balance, account_currency, user_currency)
        else
          @total_balance += a.balance
        end
      end
    end

    def perform
      result = {
        :accounts => @accounts,
        :total_balance => @total_balance
      }
    end

  end
end