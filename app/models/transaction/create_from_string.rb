class Transaction
  class CreateFromString
    def initialize(params, current_user)
      puts params
      @transaction_string = params[:transaction][:transaction_string]
      @account_id = params[:account_id]
      puts '///////////////////////////'
      puts params
      @current_user = current_user
      @cents_amount = current_user.country.currency.number_to_basic
    end

    def perform()
      if @transaction_string.length == 0
        return 'Please enter a valid transaction'
      end

      @transaction_details = parse_string()

      transaction = Transaction.new(@transaction_details)
      transaction.save

      Account.add(@account_id, @transaction_details[:amount])
    end

    private

    def parse_string()
      reg = ".+\s+[\.,]*[\+-]?[0-9\.]+$"

      name_amount = @transaction_string.strip

      if /#{reg}/.match(name_amount)
        name_amount = name_amount.split

        transaction_name = name_amount[0..-2].join(' ')

        amount = name_amount[-1]
        if amount[0] == '+'
          direction = 1
        else
          direction = -1
        end

        amount = amount.sub('+', '')
        amount = amount.sub('-', '')
        amount = amount.sub(',', '.')

        if @cents_amount > 0
          amount = (amount.to_f * @cents_amount).to_i
        else
          amount = amount.to_f.round.to_i
        end

        amount *= direction

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