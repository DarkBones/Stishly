class Account
  class GetAccounts

    def initialize(current_user)
      @current_user = current_user
      @user_currency = User.get_currency(@current_user)
      @accounts = current_user.accounts.order(:position).decorate

      if @accounts.length > 1
        all = Account.create_summary_account(current_user)
        all.balance = sum_accounts

        @accounts.insert(0, all)

        @accounts = AccountDecorator.decorate_collection(@accounts)
      end
    end

    def sum_accounts
      @total_balance = 0
      @accounts.each do |a|
        account_currency = Account.get_currency(a)
        if @user_currency.iso_code != account_currency
          @total_balance += CurrencyRate.convert(a.balance, account_currency, @user_currency)
        else
          @total_balance += a.balance
        end
      end
      return @total_balance
    end

    def perform
      result = @accounts
    end

  end
end