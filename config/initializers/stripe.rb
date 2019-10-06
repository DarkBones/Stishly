if Rails.env.production?
	public_key = Rails.application.credentials.stripe[:production][:public_key]
	private_key = Rails.application.credentials.stripe[:production][:private_key]
else
	public_key = Rails.application.credentials.stripe[:test][:public_key]
	private_key = Rails.application.credentials.stripe[:test][:private_key]
end

Rails.configuration.stripe = {
  :publishable_key => public_key,
  :secret_key      => private_key
}

Stripe.api_key = private_key