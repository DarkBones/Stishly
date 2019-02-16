class TransactionsController < ApplicationController
  def show
    @active_transaction = Transaction.find(params[:id])
    @account_id = @active_transaction.account_id
    @active_account = @active_transaction.account
  end

  def create_quick
    @user_input = params[:transaction][:user_input].to_s
    @account_id = params[:account_id].to_i

    # TODO: Create option for direction in the form
    @direction = -1

    @result = Transaction.create_from_string(params, current_user)

    # TODO: Error handling if @result != 200
    redirect_back(fallback_location: root_path)
  end

  def create
    #Transaction.create(params, current_user)
    #redirect_back(fallback_location: root_path)
    @params = params[:transaction]
    transactions = Transaction.create(params, current_user)

    @transactions_parent = []
    @transactions_child = []
    @account_names = []

    transactions.each do |t|
      t_account = current_user.accounts.find(t.account_id)
      if @params[:active_account].length == 0 || @params[:active_account] == t_account.name
        if t.parent_id
          @transactions_child.push(t)
          @account_names.push(t_account.name)
        else
          @transactions_parent.push(t)
        end
      end
    end
  end

  def show

  end
end
