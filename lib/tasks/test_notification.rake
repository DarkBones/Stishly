task :test_notification => :environment do
	Notification.create({title: "Test message", body: "This is a test", link: "test_link" }, User.find(2), true)
end