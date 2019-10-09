class Subscription < ApplicationRecord

	def self.create(user, period, params)
		return if user.subscription == period

		plan = StripePlan.where(currency: user.currency, price_eur: ENV['MONTH_PRICE_IN_EUR'].to_i).take
		free_trial = user.free_trial_eligable # if the user hasn't had a different plan before, they are entitled to the free trial

		if period == 'monthly'
			if free_trial
				plan_id = plan.plan_id_month
			else
				plan_id = plan.plan_id_month_no_trial
			end
		elsif period == 'yearly'
			if free_trial
				plan_id = plan.plan_id_year
			else
				plan_id = plan.plan_id_year_no_trial
			end
		end

		return if plan_id.nil?

		customer = self.get_stripe_customer(user, params)

		subscription = unsubscribe(customer, except_from_plan_id: plan_id)
		if subscription.nil?
			subscription = Stripe::Subscription.create({
				customer: customer.id,
		  	items: [
		  		{
		  			plan: plan_id,
		  		}
		  	],
			})
		end


		return subscription[:status]

	end

	def self.cancel(user)
		return if user.stripe_id.nil?

		customer = Stripe::Customer.retrieve(user.stripe_id)
		self.unsubscribe(customer)

		accounts = 0
		spending_accounts = 0

		user.accounts.where("is_disabled = false").order(:position).each do |a|
			accounts += 1
			spending_accounts += 1 if a.account_type == 'spend'

			if accounts > APP_CONFIG['plans']['free']['max_accounts']
				a.is_disabled = true
				a.save
			elsif spending_accounts > APP_CONFIG['plans']['free']['max_spending_accounts'] && a.account_type == 'spend'
				a.is_disabled = true
				a.save
			end
		end

		schedules = 0
		user.schedules.where("is_active = true").each do |s|
			schedules += 1

			if schedules > APP_CONFIG['plans']['free']['max_schedules']
				s.is_active = false
				s.save
			end
		end

		user.subscription = 'free'
		user.save

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
				result = s
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
