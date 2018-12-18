class Account
  class CreateFromString
    attr_reader :account_string

    def initialize(params, current_user)
      @account_string = params[:account_string]
      @current_user = current_user
      @cents_amount = User.get_currency(current_user).subunit_to_unit

    end

    def perform()
      if @account_string.length == 0
        return I18n.t('account.failure.invalid_name')
      end

      @account_details = parse_string()

      return Account.create(@account_details, @current_user)
    end

    private 

    def parse_string()
      reg = ".+\s+-?[0-9]*[\.,]?[0-9]+$"

      name_balance = @account_string.strip.split
      account_name = name_balance.join(' ')
      balance = 0

      if /#{reg}/.match(account_name)
        account_name = name_balance[0..-2].join(' ')

        if @cents_amount > 0
          balance = (name_balance[-1].sub(",", ".").to_f * @cents_amount).to_i
        else
          balance = @name_balance[-1].to_f.round.to_i
        end
      end

      result = {:name => account_name, :balance => balance}

    end
  end
end