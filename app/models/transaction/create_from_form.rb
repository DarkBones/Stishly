class Transaction
	class CreateFromForm
		def initialize(params, current_user)
			@current_user = current_user
			@params = params[:transaction]
		end
		
		def perform
			details = get_details
			
			Account.create_transaction(details, @current_user)
		end
		
private

		def get_details
			tz = TZInfo::Timezone.get(@params[:timezone])
      currency = Money::Currency.new(@params[:currency])
			details = {
        type: @params[:type].downcase,
        description: @params[:description],
        user_id: @current_user.id,
				accounts: get_accounts,
				currency: currency,
        timezone: @params[:timezone],
				local_datetime: tz.utc_to_local(Time.now),
				transactions: get_transactions(currency),
        category_id: @params[:category_id]
			}
			
			return details
		end

		def get_accounts
			type = @params[:type].downcase
			if type == 'expense' || type == 'income'
				account_name = @params[:account]
				account = @current_user.accounts.where(name: account_name).take
				
				result = {
					account: account
				}
				
				return result
			else
				from_account_name = @params[:from_account]
				to_account_name = @params[:to_account]
				
				from_account = @current_user.accounts.where(name: from_account_name).take
				to_account = @current_user.accounts.where(name: to_account_name).take
				
				result = {
					from_account: from_account,
					to_account:	to_account
				}
				
				return result
			end
		end
		
		def get_direction
			type = @params[:type].downcase
			
			type == 'expense' ? direction = -1 : direction = 1

      return direction
		end
		
		def get_transactions(currency)
			puts @params[:multiple_transactions].class.name
      puts 'MMMMMMMMMMMMM'
			if @params[:multiple_transactions] == '1'
        puts 'mmmmmmmmmmmmmmm'
				return parse_multiple_transactions(currency, get_direction)
			else
        amount = convert_amount(@params[:amount], currency, get_direction)
				return {
					transactions: [{
            description: @params[:description],
            user_id: @current_user.id,
            amount: amount,
            currency: currency.iso_code
          }],
          total_amount: amount
				}
			end
			
		end
		
		def parse_multiple_transactions(currency, direction)
			transactions = []

      total_amount = 0
			
			reg = ".+\s+[\.,]*[0-9\.]+$"
			
			transaction_text = @params[:transactions]
			transaction_list = transaction_text.split("\n")
			
			transaction_list.each do |t_name_amount|
        t_name_amount.strip!
				if /#{reg}/.match(t_name_amount)
					name_amount = t_name_amount.split
					
					transaction_name = name_amount[0..-2].join(' ')
					
					amount = name_amount[-1]
					
					amount = amount.sub(',', '.')
					
					amount = convert_amount(amount, currency, direction)
          total_amount += amount
					
					transaction = {
						description: transaction_name,
						user_id: @current_user.id,
						amount: amount,
						currency: currency.iso_code
					}
					
					transactions.push(transaction)
				end
			end
			
			return {
        transactions: transactions,
        total_amount: total_amount
      }
		end
		
		def convert_amount(amount, currency, direction)
			if currency.subunit_to_unit > 0
				amount = (amount.to_f * currency.subunit_to_unit).round.to_i
			end
			
			return amount * direction
		end
		
	end
end

=begin
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
=end
