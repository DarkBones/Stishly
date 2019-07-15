class User
  class SetupUserData

  	def initialize(current_user, params)
  		@current_user = current_user
  		@params = params
  	end

  	def perform
  		account_params = get_account_params(@params)
  	end

private

		def get_account_params(params)
			accounts = []

			params.keys.each do |k|
				if k.starts_with?("account_name_")
					idx = k.split("_")[-1]
					account = {
						name: params["account_name_#{idx}"],
						balance: Currency.float_to_int(params["account_balance_#{idx}"], params["account_currency_#{idx}"]),
						currency: params["account_currency_#{idx}"],
						is_default: idx == "0"
					}
					accounts.push(account)
				end
			end

			return accounts.to_yaml
		end

  end
end