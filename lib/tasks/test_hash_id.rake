task :test_hash_id => :environment do
	20.times do
		puts SecureRandom.urlsafe_base64(9)
	end
end