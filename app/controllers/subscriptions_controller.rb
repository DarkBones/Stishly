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
			
			if status == 'active' || 'trialing'
				current_user.subscription = params[:plan]
				current_user.free_trial_eligable = false
				current_user.save

				current_user.accounts.where("is_disabled = true").each do |a|
					a.is_disabled = false
					a.save
				end

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

end
