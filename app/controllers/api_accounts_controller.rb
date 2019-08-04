class ApiAccountsController < BaseApiController

	def index
		accounts = JSON.parse(@user.accounts.to_json)
		accounts = prepare_json(accounts)

		render json: accounts, status: :ok
	end

	def show
		render json: "bad request", status: :bad_request and return unless params[:account]

		account = @user.accounts.where(name: params[:account]).take
		render json: "not found", status: :not_found and return if account.nil?

		account = JSON.parse(account.to_json)
		account = prepare_json(account)

		render json: account
	end

	def currency
		render json: "bad request", status: :bad_request and return unless params[:account]

		account = @user.accounts.where(name: params[:account]).take
		render json: "not found", status: :not_found and return if account.nil?

		render json: Money::Currency.new(account.currency).to_json
	end

end
