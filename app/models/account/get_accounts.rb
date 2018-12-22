class Account
  class GetAccounts

    def initialize(current_user)
      @accounts = current_user.accounts.order(:position)
      user_currency = User.get_currency(current_user)
      @total_balance = 0
      @accounts.each do |a|
        account_currency = Account.get_currency(a.id, current_user)
        if user_currency.iso_code != account_currency
          @total_balance += CurrencyRate.convert(a.balance, account_currency, user_currency)
        else
          @total_balance += a.balance
        end
      end
    end

    def initialize_OLD(current_user)
      @accounts = current_user.accounts.order(:position).to_a

      if @accounts.length > 1
        all = current_user.accounts.build
        all.id = 175
        all.name = 'FFFF ALL'
        all.balance = 9999999999
        all.currency = "EUR"

        5.times do puts "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM" end
        puts all.name

        @accounts.push(all)
      end
    end

    def perform
      result = @accounts
    end

  end
end