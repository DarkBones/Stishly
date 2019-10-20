class Budget < ApplicationRecord
	include Friendlyable

	belongs_to :user
	belongs_to :category

	attr_accessor :spent, :percentage, :color

	def self.create_budget(user, params)
		currency = Money::Currency.new(user.currency)
		
		category = user.categories.friendly.find(params[:category_id])
		amount = params[:amount].to_f * currency.subunit_to_unit
		
		budget = user.budgets.create({
			category_id: category.id,
			amount: amount
		})

		budget.save

		return budget
	end

	def self.get_budgets(user)
		budgets = []

		start_date = Schedule.get_previous_main_date(user)
		all_transactions = user.transactions.where("
			is_scheduled = false
			AND local_datetime IS NOT NULL
			AND is_main = true
			AND is_cancelled = false
			AND is_queued = false
			AND category_id IS NOT NULL
			AND scheduled_date IS NULL
			")

		user.budgets.order(:amount).includes(:category).reverse.each do |budget|
			spent = all_transactions.where(category_id: budget.category_id).sum(:user_currency_amount) * -1
			spent = Category.get_amount(budget.category, start_date: start_date) * -1
			percentage = ((100.to_f / budget.amount) * spent).round

			if percentage < 0
				percentage = 0
			end

			if percentage < 75
				color = 'success'
			elsif percentage < 95
				color = 'warning'
			else
				color = 'danger'
			end

			budget.spent = spent
			budget.percentage = percentage
			budget.color = color

			budgets.push(budget)
		end

		return budgets

	end

end
