task :test_sendgrid => :environment do
	puts "Running sendgrid test"
	
	require "uri"
	require "net/http"

	url = URI.parse("https://api.sendgrid.com/v3/contactdb/recipients")

	puts url.host
	puts url.port

	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true

	req = Net::HTTP::Post.new(url.path)
	req["Authorization"] = "Bearer #{Rails.application.credentials.sendgrid[:api_key]}"
	req["Content-Type"] = "application/json"
	req["data"] = "[{\"email\": \"test@stishly.com\"}]"
	#req.data = "[{\"email\": \"test@stishly\"}]"

	response = http.request(req)

	puts response.to_yaml

	puts "Finished running sendgrid test"
end

task :test_list => :environment do
	puts "running test list"

	url = URI.parse("https://api.sendgrid.com/v3/contactdb/lists")

	puts url.host
	puts url.port

	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true

	req = Net::HTTP::Get.new(url.path)
	req["Authorization"] = "Bearer #{Rails.application.credentials.sendgrid[:api_key]}"
	req["Content-Type"] = "application/json"
	#req["data"] = "[{\"email\": \"test@stishly\"}]"

	response = http.request(req)
	puts response.to_yaml

	puts "finished running test list"
end