class SubscriptionsController < ApplicationController

	def index
		@plan = StripePlan.get_plan(current_user)
	end

	def new
	end

	def create
		begin
			plan = params[:plan]
			Subscription.create(current_user, plan, params)
		rescue Stripe::CardError => e
		  flash[:error] = e.message
		  redirect_back(fallback_location: root_path)
		end

	end

end
