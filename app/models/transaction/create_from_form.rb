class Transaction
  class CreateFromForm
    def initialize(params, current_user)
      @current_user = current_user
      @params = params[:transaction]

      @description = @params[:description]
      @type = @params[:type].downcase
      @category_id = @params[:category_id]

    end

    def perform
      if @type == 'expense' || @type == 'income'
        @account_name = @params[:account]
        @account_id = @current_user.accounts.where(name: @account_name).take.id
      else
        @from_account_name = params[:from_account]
        @to_account_name = params[:to_account]

        @from_account_id = @current_user.accounts.where(name: @from_account_name).take.id
        @to_account_id = @current_user.accounts.where(name: @to_account_name).take.id
      end

      @direction = 1
      if @type == 'expense'
        @direction = -1
      end

      @currency = Money::Currency.new(@params[:currency])

      tz = TZInfo::Timezone.get(@params[:timezone])
      @local_datetime = tz.utc_to_local(Time.now)

      if @params[:multiple_transactions] == true
        # TODO: Parse multiple transactions
      else
        @amount = @params[:amount]

        puts '//////////////////////'

        if Account.find(@account_id).currency != @params[:currency]
          @account_currency_amount = CurrencyRate.convert(@amount, @currency, Money::Currency.new(Account.find(@account_id).currency))
        else
          @account_currency_amount = convert_amount(@params[:amount])
        end

        @amount = convert_amount(@params[:amount])

        t = Transaction.new
        t.user_id = @current_user.id
        t.amount = @amount
        t.direction = @direction
        t.description = @description
        t.account_id = @account_id
        t.currency = @params[:currency]
        t.timezone = @params[:timezone]
        t.local_datetime = @local_datetime
        t.account_currency_amount = @account_currency_amount
        t.category_id = @category_id
        puts t
        t.save
      end
    end

    def convert_amount(amount)
      if @currency.subunit_to_unit > 0
        amount = (amount.to_f * @currency.subunit_to_unit).round.to_i
      end

      return amount * @direction
    end

  end
end