class BudgetsController < ApplicationController

	def index
		@start_date = Schedule.get_previous_main_date(current_user)
		@end_date = Schedule.get_next_main_date(current_user)
		@budgets = Budget.get_budgets(current_user)
	end

	def create
		@budget = Budget.create_budget(current_user, budget_params)
	end

	def update
		budget = current_user.budgets.friendly.find(params[:id])
		if params[:delete].nil?
			@budget = Budget.update(current_user, budget, budget_params)
			render "create"
		else
			@budget = budget.hash_id
			budget.destroy
			render "destroy"
		end

	end

private

	def budget_params
		params.require(:budget).permit(
			:category_id,
			:amount,
		)
	end

end
