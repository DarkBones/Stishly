class Transaction
  class CreateFromForm

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
      @reg = ".+\s+[\.,]*-?[0-9\.,]*$"
    end

    def perform
      base_transactions = get_base_transactions(@params)
      base_transactions = link_transferred_transactions(@params, base_transactions)
      puts "......................."
      puts base_transactions.to_yaml if @params[:type] == 'transfer' && @params[:multiple] == 'multiple'
    end


private

    def get_base_transactions(params, transferred=false, ignore_transfer=false)
      transactions = []

      account = get_account(params, transferred)
      currency = get_currency(params)

      current_transaction = {
        description: params[:description],
        amount: get_total_amount(params, transferred),
        currency: currency,
        account: account.name
      }
      transactions.push(current_transaction)


      if params[:multiple] == 'multiple'
        transactions_string = params[:transactions].split("\n")
        transactions_string.each do |t_name_amount|
          if /#{@reg}/.match(t_name_amount)
            name_amount = t_name_amount.split(' ')
            amount_string = name_amount[-1]

            amount = 0
            amount = amount_string.to_f if amount.respond_to? "to_f"

            description = name_amount[0..-2].join(' ')

            child_params = params.dup
            child_params[:multiple] = 'single'
            child_params[:description] = description
            child_params[:amount] = amount

            current_transaction[:children] ||= []
            current_transaction[:children].push(get_base_transactions(child_params, transferred, true))
          end
        end
      end

      if params[:type] == 'transfer' && !ignore_transfer
        transactions += get_base_transactions(params, true) unless transferred
      end

      return transactions

    end

    def link_transferred_transactions(params, base_transactions)
      return base_transactions unless params[:type] == 'transfer'

      idxs = []
      base_transactions.each_with_index do |bt, idx|
        idxs.push(idx) if bt[:parent_id].nil?
      end

      if idxs.length == 2
        base_transactions[idxs[0]][:transfer_transaction_id] = idxs[1]
        base_transactions[idxs[1]][:transfer_transaction_id] = idxs[0]
      end

      return base_transactions
    end

    # returns the account object
    def get_account(params, transferred=false)
      return Account.get_from_name(params[:account], @current_user) unless params[:type] == 'transfer'

      if transferred
        return Account.get_from_name(params[:to_account], @current_user)
      else
        return Account.get_from_name(params[:from_account], @current_user)
      end
    end

    # returns the currency iso code
    def get_currency(params)
      return params[:currency] unless params[:type] == 'transfer'

      return Account.get_from_name(params[:from_account], @current_user).currency
    end

    # returns the total transaction amount in float
    def get_total_amount(params, transferred)
      total = 0

      if params[:multiple] == 'single'
        total = params[:amount].to_f
        #total *= -1 if transferred
        return total * get_direction(params, transferred)
      end

      transactions = params[:transactions].split("\n")
      transactions.each do |t_name_amount|
        if /#{@reg}/.match(t_name_amount)
          amount = t_name_amount.split(' ')[-1]
          total += amount.to_f if amount.respond_to? "to_f"
        end
      end

      #total *= -1 if transferred

      return total * get_direction(params, transferred)
    end

    def get_direction(params, transferred)
      direction = 1
      if params[:type] == 'expense'
        direction = -1
      elsif params[:type] == 'transfer' && !transferred
        direction = -1
      end

      return direction
    end

    class BaseTransaction

      def initialize(params, current_user)
        # description
        # amount (float)
        # currency
        # account
        # parent id
      end

    end

  end
end