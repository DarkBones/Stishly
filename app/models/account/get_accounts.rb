class Account
  class GetAccounts

    def initialize(current_user)
      @accounts = current_user.accounts.order(:position)
      @total_balance = @accounts.sum(:balance)
    end

    def perform
      result = {
        :accounts => @accounts,
        :total_balance => @total_balance
      }
    end

  end
end