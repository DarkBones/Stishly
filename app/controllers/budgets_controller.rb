class BudgetsController < ApplicationController

	def index
		#@budgets = current_user.budgets.order(:amount).includes(:category).reverse
		@budgets = Budget.get_budgets(current_user)
	end

	def create
		Budget.create_budget(current_user, create_params)
	end

private

	def create_params
		params.require(:budget).permit(
			:category_id,
			:amount,
		)
	end

end
