class SubscriptionsController < ApplicationController

	def index
		@plan = StripePlan.get_plan(current_user)
	end

	def new
	end

	def create
		begin
			plan = params[:plan]
			status = Subscription.create(current_user, plan, params)
			
			if status == 'active'
				current_user.subscription = params[:plan]
				current_user.free_trial_eligable = false
				current_user.save

				flash[:message] = "Thank you. Enjoy using premium!"
				redirect_to root_path
			else
				flash[:error] = "Something went wrong. Please try again."
				redirect_back(fallback_location: root_path)
			end
		rescue Stripe::CardError => e
		  flash[:error] = e.message
		  redirect_back(fallback_location: root_path)
		end

	end

	def unsubscribe
		Subscription.cancel(current_user)
		current_user.subscription = 'free'
		current_user.save

		flash[:message] = "You have been unsubscibed"
		redirect_to root_path
	end

	def over_usage
		@accounts = current_user.accounts.order(:position)
		@schedules = current_user.schedules.where("type_of != 'main'")

		@overused_accounts = @accounts.length > APP_CONFIG['plans']['free']['max_accounts']
		@overused_spending_accounts = @accounts.where("account_type = 'spend'").length > APP_CONFIG['plans']['free']['max_spending_accounts']
		@overused_schedules = @schedules.length > APP_CONFIG['plans']['free']['max_schedules']
	end

	def show
	end

end
