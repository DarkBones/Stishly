class ApiCurrenciesController < BaseApiController

	def index
		render json: Money::Currency.table
	end

	def show
		begin
			currency = Money::Currency.new(params[:currency])

			currency = JSON.parse(currency.to_json)
			currency = prepare_json(currency)

			render json: currency
		rescue
			render json: "Invalid currency", status: :not_found and return
		end
	end

	def convert
		begin
			from_currency = Money::Currency.new(params[:currency])
			to_currency = Money::Currency.new(params[:to_currency])
			render json: CurrencyRate.convert(params[:amount].to_i, from_currency, to_currency) and return
		rescue
			render json: "Invalid currency", status: :not_found and return
		end

	end

	def rate
		begin
			from_currency = Money::Currency.new(params[:currency])
			to_currency = Money::Currency.new(params[:to_currency])
			render json: CurrencyRate.get_rate(from_currency.iso_code, to_currency.iso_code) and return
		rescue
			render json: "Invalid currency", status: :not_found and return
		end
	end

	def format
		begin
			currency = Money::Currency.new(params[:currency])
		rescue
			render json: "Invalid currency", status: :not_found and return
		end

		if params[:float]
			render json: Account.format_currency_float(params[:amount].sub('$', '.'), params[:currency])
		else
			render json: Account.format_currency(params[:amount], params[:currency])
		end
	end

	def format_currency
    if params[:float]
      render json: Account.format_currency_float(params[:amount].sub('$', '.'), params[:currency])
    else
      render json: Account.format_currency(params[:amount], params[:currency])
    end
  end

  # gets the currency rates between two given accounts, for transferring purposes
  def transfer_rate
    from_account = Account.get_from_name(params[:from], current_user)
    to_account = Account.get_from_name(params[:to], current_user)

    render json: "not found", status: :not_found and return if from_account.nil? || to_account.nil?

    currency_rate = 1

    if from_account.currency != to_account.currency
      currency_rate = CurrencyRate.get_rate(from_account.currency, to_account.currency)
    end

    render json: {
      from_account: {
        currency: from_account.currency
      },
      to_account: {
        currency: to_account.currency
      },
      currency_rate: currency_rate
    }
  end

end
