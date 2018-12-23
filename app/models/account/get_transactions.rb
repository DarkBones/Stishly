class Account
  
  class GetTransactions
    
    def initialize(account, page, current_user)
      @account = account
      @page = page
      @id = account.id
      @current_user = current_user
      @transactions = get_transactions()
    end

    def perform
      return @transactions
    end

    private

    def get_transactions
      if @account.is_real
        transactions = @account.transactions.order(:created_at).reverse_order().page(@page).per_page(30)
      else
        transactions = Transaction.where(user_id: @current_user.id).order(:created_at).reverse_order().page(@page).per_page(30)
      end
    end

  end

end
