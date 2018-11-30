class Transaction
  class CreateFromString
    def initialize(params, current_user)
      puts params
      @transaction_string = params[:transaction][:transaction_string]
      @direction = -1
      @account_id = params[:account_id]
      @current_user = current_user
      @cents_amount = current_user.country.currency.number_to_basic
    end

    def perform()
      if @transaction_string.length == 0
        return 'Please enter a valid transaction'
      end

      @transaction_details = parse_string()

      transaction = Transaction.new(@transaction_details)
    end

    private

    def parse_string()
      reg = ".+\s+[\.,]*-?[0-9\.]+$"

      name_amount = @transaction_string.strip

      if /#{reg}/.match(name_amount)
        name_amount = name_amount.split

        transaction_name = name_amount[0..-2].join(' ')

        if @cents_amount > 0
          amount = (name_amount[-1].sub(",", ".").to_f * @cents_amount).to_i
        else
          amount = name_amount[-1].to_f.round.to_i
        end

        amount *= @direction

        result = { 
          :user_id => @current_user.id, 
          :description => transaction_name, 
          :amount => amount ,
          :account_id => @account_id,
          :timezone => @current_user.timezone
        }

        return result
      end
    end
  end
end