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
      if @account.persisted?
        @account.transactions.where(parent_id: nil, is_scheduled: 0).order(:local_datetime).reverse_order().includes(:children, :category).page(@page).per_page(page_length)
      else
        @current_user.transactions.where(parent_id: nil, is_scheduled: 0).order(:local_datetime).reverse_order().includes(:children, :category).page(@page).per_page(page_length)
      end
    end

  end

end
