class ApiGuiController < BaseApiBrowserController

	def account_display_balance
		render json: "bad request", status: :bad_request and return unless params[:account] && params[:amount] && params[:from] && params[:to] && params[:add]

		begin
			from_currency = Money::Currency.new(params[:from])
			to_currency = Money::Currency.new(params[:to])
		rescue
			render json: "Invalid currency", status: :bad_request and return
		end

		render json: Account.get_display_balance_html(params)
	end

private
	
	def display_balance_params
		params.permit(:account, :amount, :from, :to, :add)
	end

end
