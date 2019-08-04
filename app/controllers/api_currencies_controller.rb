class ApiCurrenciesController < BaseApiController

	def index
		render json: Money::Currency.table
	end

	def show
		render json: "bad request", status: :bad_request and return unless params[:currency]

		begin
			currency = Money::Currency.new(params[:currency])

			currency = JSON.parse(currency.to_json)
			currency = prepare_json(currency)

			render json: currency
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end
	end

	def convert
		render json: "bad request", status: :bad_request and return unless params[:currency] && params[:to_currency] && params[:amount]

		begin
			from_currency = Money::Currency.new(params[:currency])
			to_currency = Money::Currency.new(params[:to_currency])
			render json: CurrencyRate.convert(params[:amount].to_i, from_currency, to_currency) and return
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end

	end

	def rate
		render json: "bad request", status: :bad_request and return unless params[:currency] && params[:to_currency]

		begin
			from_currency = Money::Currency.new(params[:currency])
			to_currency = Money::Currency.new(params[:to_currency])
			render json: CurrencyRate.get_rate(from_currency.iso_code, to_currency.iso_code) and return
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end
	end

	def format
		render json: "bad request", status: :bad_request and return unless params[:currency] && params[:amount]

		begin
			currency = Money::Currency.new(params[:currency])
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end

		render json: Account.format_currency(params[:amount], params[:currency])
	end

end
