class ApiTransactionsController < BaseApiController

	def show
		render json: "bad request", status: :bad_request and return unless params[:id]

		transaction = @user.transactions.find(params[:id])
		render json: "not found", status: :not_found and return if transaction.nil?

		transaction = JSON.parse(transaction.to_json)
		transaction = prepare_json(transaction)

		render json: transaction
	end

end
