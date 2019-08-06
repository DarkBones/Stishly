class ApiUsersController < BaseApiController

	def subscription
		subscription_tier = @user.subscription_tier
		subscription_tier ||= SubscriptionTier.where(name: "Free").take
		subscription_tier = JSON.parse(subscription_tier.to_json)

		render json: prepare_json(subscription_tier, ["name", "created_at", "updated_at", "id"])
	end

	def currency
		render json: Money::Currency.new(@user.currency)
	end

	def week_start
		week_start = SettingValue.get_setting(@user, "week_start")
		unless week_start
			week_start = @user.country.week_start
		end

		render json: week_start
	end

end
