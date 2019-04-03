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
      page_length = APP_CONFIG['ui']['transactions']['page_length']
      if @account.is_real
        @account.transactions.where(parent_id: nil).order(:local_datetime).reverse_order().includes(:children, :category).page(@page).per_page(page_length)
      else
        #transactions = Transaction.where(user_id: @current_user.id).order(:local_datetime).reverse_order().page(@page).per_page(30)
        @current_user.transactions.where(parent_id: nil).order(:local_datetime).reverse_order().includes(:children, :category, :account).page(@page).per_page(page_length)
      end
    end

  end

end
