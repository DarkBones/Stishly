class BaseApiController < ApplicationController
	skip_before_action :authenticate_user!
	skip_before_action :daily_budget, :setup_wizzard, :check_subscription
	before_action :parse_request, :authenticate_user_from_token!

private
	
	# authenticate the user
	def authenticate_user_from_token!
		# TODO: token authentication
		if current_user
			@user = current_user
		else
			render json: "unauthorized", status: :unauthorized
		end
	end

	# parse the request to json format
	def parse_request
		@json = {}
		@json = JSON.parse(request.body.read) if request.body.read.length > 0

		@expand = []
		@expand = params[:expand].sub(" ", "").split(",") if params[:expand]
	end

	# expand fields specified in expand parameter
	def expand_fields(json)

		if @expand.include? "currency"
			json.each {|k,v| json[k] = JSON.parse(Money::Currency.new(v).to_json) if k == "currency" }
		end

		return json

	end

	# filter the fields (hide true ids, replace them with hashed ids)
	def filter_fields(json, additional_fields=[])
		#json.each {|k,v| json[k] = @user.email if k == "user_id"}
		
		json = reject_key(json, "user_id")
		json = reject_key(json, "id")
		json = reject_key(json, "transfer_transaction_id")
		json = reject_key(json, "transfer_account_id")
		json = reject_key(json, "category_id")
		json = reject_key(json, "parent_id")
		json = reject_key(json, "category_id")
		json = reject_key(json, "account_id")
		json = reject_key(json, "scheduled_transaction_id")
		json = reject_key(json, "schedule_id")
		additional_fields.each do |f|
			json = reject_key(json, f)
		end

		# rename hash_id to id
		json = rename_key(json, "hash_id", "id")

		# move the id key to the beginning of the hash
		json = move_key_to_start(json, "id")

		return json
	end

	# takes a key and moves it to the start of the hash
	def move_key_to_start(h, key)
		#tmp_h = {}
		#tmp_h[key] = h[key]
		#tmp_h.merge!(h)
		#return tmp_h
		if h.is_a? Array
			h.each_with_index do |a, idx|
				h[idx] = move_key_to_start(a, key)
			end
		elsif h.is_a? Hash
			tmp_h = {}
			tmp_h[key] = h[key]
			tmp_h.merge!(h)
			h = tmp_h
		end

		return h
	end

	# renames a key
	def rename_key(h, from, to)
		if h.is_a? Array
			h.each_with_index do |a, idx|
				h[idx] = rename_key(a, from, to)
			end
		elsif h.is_a? Hash
			h[to] = h.delete(from)
		end

		return h
	end

	# recursively removes a key
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

	# prepare the json
	def prepare_json(json, filter_fields=[])
		json = filter_fields(json, filter_fields)
		json = expand_fields(json)

		return json
	end

end
