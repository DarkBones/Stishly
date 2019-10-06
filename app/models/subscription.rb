class Subscription < ApplicationRecord

	def self.create(user, plan, params)
		#return if user.subscription == plan
		plan_name = plan

		plan = APP_CONFIG['plans'][plan]

		customer = self.get_stripe_customer(user, params)

		if unsubscribe(customer, except_from_plan_id: plan['stripe_id']).nil?
			subscription = Stripe::Subscription.create({
				customer: customer.id,
		  	items: [
		  		{
		  			plan: 'plan_FwTAzDX2PVq6ZQ'
		  		}
		  	],
			})
		end


		user.subscription = plan_name
		user.save

	end

	def self.cancel(user)
		customer = Stripe::Customer.retrieve(user.stripe_id)
		self.unsubscribe(customer)
	end

private

	# checks if a customer is subscribed to a given plan
	def self.is_subscribed(customer, plan_id)
		customer[:subscriptions].each do |s|
			return true if s[:plan][:id] == plan_id
		end

		return false
	end

	# unsubscribes a customer from all subscriptions, except for a given plan id
	# if a subscription is kept it returns the subscription id
	def self.unsubscribe(customer, except_from_plan_id: nil)
		result = nil

		customer[:subscriptions].each do |s|
			if except_from_plan_id.nil?
				Stripe::Subscription.delete(s[:id])
			elsif s[:plan][:id] != except_from_plan_id || !result.nil?
				Stripe::Subscription.delete(s[:id])
			else
				result = s[:id]
			end
		end

		return result
	end

	# creates a stripe customer if none exists and returns it
	def self.get_stripe_customer(user, params)

		if user.stripe_id.nil?
			customer = self.create_stripe_customer(user, params)
		else
			begin
				customer = Stripe::Customer.retrieve(user.stripe_id)
			rescue
				customer = self.create_stripe_customer(user, params)
			end
		end

		return customer

	end

	# create a stripe customer
	def self.create_stripe_customer(user, params)
		customer = Stripe::Customer.create({
			email: params[:stripeEmail],
	    source: params[:stripeToken],
		})

		user.stripe_id = customer.id
		user.save

		return customer
	end

end
