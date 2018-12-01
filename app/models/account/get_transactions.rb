class Account
  class GetTransactions

    def initialize(params, current_user)
      @page = params[:page]
      @id = params[:id]
      @current_user = current_user
      @account_name = get_account_name()
      @transactions = get_transactions()
    end

    def perform
      result = { :id => @id, :account_name => @account_name, :transactions => @transactions }
    end

    private

    def get_account_name()
      if @id != 'all'
        result = Account.find(@id).name
      else
        result = 'All'
      end

      return result
    end

    def get_transactions()
      if @id != 'all'
        transactions = Transaction.where("account_id" => @id, "user_id" => @current_user.id).order(:created_at).reverse_order().page(@page).per_page(30)
      else
        transactions = Transaction.where("user_id" => @current_user.id).order(:created_at).reverse_order().page(@page).per_page(30)
      end
    end

  end

end
