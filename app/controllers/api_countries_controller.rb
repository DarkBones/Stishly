class ApiCountriesController < BaseApiController

	def index
		render json: ISO3166::Country.all
	end

	def show
		country = ISO3166::Country[params[:country]]

		render json: "invalid country", status: :not_found and return if country.nil?
		render json: country
	end

	def currency
		country = ISO3166::Country[params[:country]]

		render json: "invalid country", status: :not_found and return if country.nil?

		begin
			currency = Money::Currency.new(country.currency)
			render json: currency
		rescue
			render json: "invalid currency", status: :not_found
		end
	end

end
