class StripePlan < ApplicationRecord

	def self.get_plan(user)
		currency = user.currency

		unless ENV['STRIPE_SUPPORTED_CURRENCIES'].split(" ").include? currency
			currency = 'USD'
		end

		plan = StripePlan.where(currency: currency, price_eur: ENV['MONTH_PRICE_IN_EUR'].to_i).take

		if plan.nil?
			plan = self.create_plan(user.currency)
		end

		return plan
	end

	def self.create_plan(currency)
		currency = Money::Currency.new(currency)

		amount = CurrencyRate.convert(ENV['MONTH_PRICE_IN_EUR'].to_i, Money::Currency.new('EUR'), currency)

		if currency.subunit_to_unit > 1
			amount_month = ((amount.to_f / currency.subunit_to_unit).round) * currency.subunit_to_unit
			amount_year = ((((amount_month.to_f * 10) / currency.subunit_to_unit) / 12).round)

			if (amount_year * currency.subunit_to_unit) >= amount_month && amount_year > 2
				amount_year -= 1
			end
			amount_year *= currency.subunit_to_unit

			amount_month -= 1
			amount_year -= 1
			
			amount_year *= 12

		else
			amount_month = ((amount.to_f / 100).round) * 100
			amount_year = ((((amount_month.to_f * 10) / 100) / 12).round) * 100

			amount_month -= 1
			amount_year -= 1

			amount_year *= 12
		end

		plan_month = Stripe::Plan.create({
		  currency: currency.iso_code.downcase,
		  interval: 'month',
		  amount: amount_month,
		  product: ENV['STRIPE_PRODUCT_ID'],
		  nickname: "#{currency.iso_code} Month",
		  trial_period_days: 7
		})

		plan_year = Stripe::Plan.create({
		  currency: currency.iso_code.downcase,
		  interval: 'month',
		  interval_count: 12,
		  amount: amount_year,
		  product: ENV['STRIPE_PRODUCT_ID'],
		  nickname: "#{currency.iso_code} Year",
		  trial_period_days: 7
		})

		plan = StripePlan.create({
			currency: currency.iso_code,
			price_eur: ENV['MONTH_PRICE_IN_EUR'].to_i,
			price_month: amount_month,
			price_year: amount_year,
			plan_id_month: plan_month.id,
			plan_id_year: plan_year.id,
		})

		plan.save
		return plan

	end

end
