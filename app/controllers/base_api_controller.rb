class BaseApiController < ApplicationController
	skip_before_action :authenticate_user!
	before_action :parse_request, :authenticate_user_from_token!

private
	
	def authenticate_user_from_token!
		# TODO: token authentication
		if current_user
			@user = current_user
		else
			render json: "unauthorized", status: :unauthorized
		end
	end

	def parse_request
		@json = {}
		@json = JSON.parse(request.body.read) if request.body.read.length > 0

		@expand = []
		@expand = params[:expand].sub(" ", "").split(",") if params[:expand]
	end

	def expand_fields_OLD(json)
		#if @expand.include? "currency"
		#	if json.class = Array
		#		item['user'] = @user.to_json
		#	else
		#
		#	end
		#end

		if @expand.include? "currency"
			if json.class == Array
				json.each do |item|
					item['currency'] = JSON.parse(Money::Currency.new(item['currency']).to_json) if item['currency']
				end
			else
				json['currency'] = JSON.parse(Money::Currency.new(json['currency']).to_json) if json['currency']
			end
		end

		return json
	end

	def expand_fields(json)

		if @expand.include? "currency"
			json.each {|k,v| json[k] = JSON.parse(Money::Currency.new(v).to_json) if k == "currency" }
		end

		return json

	end

	def filter_fields(json, additional_fields=[])
		#json.each {|k,v| json[k] = @user.email if k == "user_id"}
		
		json = reject_key(json, "user_id")
		additional_fields.each do |f|
			json = reject_key(json, f)
		end

		return json
	end

	def reject_key(h, key)
		if h.is_a? Array
			h.each_with_index do |a, idx|
				h[idx] = reject_key(a, key)
			end
		elsif h.is_a? Hash
			h = h.reject {|k,v| k == key}
		end

		return h
	end

	def prepare_json(json, filter_fields=[])
		json = filter_fields(json, filter_fields)
		json = expand_fields(json)

		return json
	end

end
