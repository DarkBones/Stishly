Rails.configuration.stripe = {
  :publishable_key => Rails.application.credentials.stripe[:public_key],
  :secret_key      => Rails.application.credentials.stripe[:private_key]
}

Stripe.api_key = Rails.application.credentials.stripe[:private_key]