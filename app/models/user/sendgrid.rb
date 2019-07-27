class User
	class Sendgrid

		def initialize(current_user)
			require "uri"
			require "net/http"

      @current_user = current_user
    end

    def add_to_marketing
			data = {}

    	lists = []
    	Rails.application.credentials.sendgrid[:marketing_lists].each do |l|
				lists.push(l[1])
			end

			contacts = []
			contact = {
				first_name: @current_user.first_name,
				last_name: @current_user.last_name,
				email: @current_user.email
			}

			contacts.push(contact)

			data[:list_ids] = lists
			data[:contacts] = contacts

			response = request_put("https://api.sendgrid.com/v3/marketing/contacts", data)

			return response
    end

private

		def request_put(url, data)
			url = URI.parse(url)

			http = create_http(url)

			req = Net::HTTP::Put.new(url.path)
			req["Authorization"] = "Bearer #{Rails.application.credentials.sendgrid[:api_key]}"
			req["Content-Type"] = "application/json"
			req.body = data.to_json

			response = http.request(req)

			return response

		end

		def create_http(url)
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			return http
		end

	end
end