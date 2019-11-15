APP_CONFIG = YAML.load_file(Rails.root.join('config/system_parameters.yml'))

ENV['AWS_REGION'] = "us-east-2"
ENV['AWS_ACCESS_KEY_ID'] = Rails.application.credentials.aws[:access_key_id]
ENV['AWS_SECRET_ACCESS_KEY'] = Rails.application.credentials.aws[:secret_access_key]

ENV['EMAIL_ENCRYPTION_KEY'] = Rails.application.credentials.pii[:encryption_key]
ENV['EMAIL_BLIND_INDEX_KEY'] = Rails.application.credentials.pii[:blind_index_key]

if Rails.env.production?
	ENV['STRIPE_PUBLIC_KEY'] = Rails.application.credentials.stripe[:production][:public_key]
	ENV['STRIPE_PRODUCT_ID'] = 'prod_FySwz9v0vantDh'
else
	ENV['STRIPE_PUBLIC_KEY'] = Rails.application.credentials.stripe[:test][:public_key]
	ENV['STRIPE_PRODUCT_ID'] = 'prod_FwcWr47UyLCmvt'
end

ENV['STRIPE_SUPPORTED_CURRENCIES'] = 'USD AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BIF BMD BND BOB BRL BSD BWP BZD CAD CDF CHF CLP CNY COP CRC CVE CZK DJF DKK DOP DZD EGP ETB EUR FJD FKP GBP GEL GIP GMD GNF GTQ GYD HKD HNL HRK HTG HUF IDR ILS INR ISK JMD JPY KES KGS KHR KMF KRW KYD KZT LAK LBP LKR LRD LSL MAD MDL MGA MKD MMK MNT MOP MRO MUR MVR MWK MXN MYR MZN NAD NGN NIO NOK NPR NZD PAB PEN PGK PHP PKR PLN PYG QAR RON RSD RUB RWF SAR SBD SCR SEK SGD SHP SLL SOS SRD STD SZL THB TJS TOP TRY TTD TWD TZS UAH UGX UYU UZS VND VUV WST XAF XCD XOF XPF YER ZAR ZMW'
ENV['MONTH_PRICE_IN_EUR'] = '600'

ENV['SENDGRID_API_KEY'] = Rails.application.credentials.sendgrid[:send_api_key]

ENV['DEVISE_JWT_SECRET_KEY'] = '14304f8900f8e6077c21c457c2e5cc9d335505c03c73cf61152b302f3130b7397f4920813a65a2699b4fbb2b8bc31e8f8c27f04f27979fee0a6ddf7624274575'