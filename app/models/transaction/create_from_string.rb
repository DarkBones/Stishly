class Transaction
  class CreateFromString
    def initialize(params, current_user)
      @transaction_string = params[:transaction][:transaction_string]
      @account_id = params[:account_id]
      @current_user = current_user
      @account = Account.find(params[:account_id].to_i)
      
      if !params[:transaction][:currency].nil?
        @currency = Money::Currency.new(params[:transaction][:currency])
      else
        @currency = Account.get_currency(@account)
      end

      @cents_amount = @currency.subunit_to_unit
    end

    def perform()
      if @transaction_string.length == 0
        return 'Please enter a valid transaction'
      end

      @transaction_details = parse_string()

      Transaction.create(@account_id, @transaction_details, @current_user)
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
          amount = (amount.to_f * @cents_amount).round.to_i
        else
          amount = amount.to_f.round.to_i
        end

        amount *= direction
        result = { 
          :user_id => @current_user.id, 
          :description => transaction_name, 
          :amount => amount ,
          :account_id => @account_id,
          :timezone => @current_user.timezone,
          :currency => @currency.iso_code
        }

        return result
      end
    end
  end
end