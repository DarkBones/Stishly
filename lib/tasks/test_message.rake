task :test_message => :environment do
	Message.create_message({title: "Test message", body: "This is a test", link: "test_link" }, User.find(2), true)
end