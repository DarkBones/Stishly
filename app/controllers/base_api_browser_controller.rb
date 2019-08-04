class BaseApiBrowserController < BaseApiController

private

	def authenticate_user_from_token!
		# this API is only accessible from the browser
		if current_user
			@user = current_user
		else
			render json: "unauthorized", status: :unauthorized
		end
	end

end
