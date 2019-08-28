task :exchange_rates => :environment do
	puts "Running exchange rates"

	CurrencyRate.update_rates

	puts "Finished running exchange rates"
end