class Account
  class NewAccount
    def initialize(params, current_user)
      @name = params[:name]
      @description = params[:description]
      @balance = params[:balance].to_f
      @currency = Money::Currency.new(params[:currency])
      @current_user = current_user
    end

    def perform()

      account_details = {
        :name => @name,
        :balance => (@balance * @currency.subunit_to_unit).to_f.round.to_i,
        :description => @description,
        :currency => @currency.iso_code
      }

      return Account.create(account_details, @current_user)
    end
  end
end