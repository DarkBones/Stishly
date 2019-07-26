task :test_sendgrid => :environment do
	puts "Running sendgrid test"
	
	require "uri"
	require "net/http"

	url = URI.parse("https://api.sendgrid.com/v3/contactdb/recipients")

	#puts url.host
	#puts url.port
	#puts "Bearer #{Rails.application.credentials.sendgrid[:api_key]}"

	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true

	req = Net::HTTP::Post.new(url.path)
	req["Authorization"] = "Bearer #{Rails.application.credentials.sendgrid[:api_key]}"
	req["Content-Type"] = "application/json"
	req["data"] = "[{\"email\": \"test@stishly.com\"}]"
	#req.data = "[{\"email\": \"test@stishly\"}]"

	response = http.request(req)

	puts response.message

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

task :test_example => :environment do
	require 'sendgrid-ruby'
	include SendGrid

	from = Email.new(email: 'test@example.com')
	to = Email.new(email: 'donkerbc@gmail.com')
	subject = 'Sending with SendGrid is Fun'
	content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
	mail = Mail.new(from, subject, to, content)

	sg = SendGrid::API.new(api_key: Rails.application.credentials.sendgrid[:api_key])
	response = sg.client.mail._('send').post(request_body: mail.to_json)
	puts response.status_code
	puts response.body
	puts response.headers

end

task :lib => :environment do
	require 'sendgrid-ruby'
	include SendGrid

	sg = SendGrid::API.new(api_key: Rails.application.credentials.sendgrid[:api_key])
	
	response = sg.lists('send')
end