task :test_notification => :environment do
	Notification.create({title: "Test message", body: "This is a test", link: "test_link" }, User.find(2), true)
end

task :test_hash_id => :environment do
	20.times do
		puts SecureRandom.urlsafe_base64(9)
	end
end