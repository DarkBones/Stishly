class Transaction
  class UpdateTransaction

  	def initialize(transaction, params, user, scheduled: false)
  		@transaction = transaction
  		@params = params
  		@user = user
  		@scheduled = scheduled
  	end

  	def perform
  		original_transaction = @transaction.dup
  		new_transaction = update_transactions(@transaction, @params, @user)

  		update_account_balances(original_transaction, new_transaction, @user)

  		return new_transaction
  	end

private

		def update_account_balances(original_transaction, new_transaction, user)
			update_account_balance(original_transaction, new_transaction, user)
			update_account_balance(original_transaction.transfer_transaction, new_transaction.transfer_transaction, user)
		end

		def update_account_balance(original_transaction, new_transaction, user)
			unless original_transaction.nil?
				unless original_transaction.is_scheduled
					Account.subtract(user, original_transaction.account, original_transaction.account_currency_amount, original_transaction.local_datetime)
				end
			end

			unless new_transaction.nil?
				unless new_transaction.is_scheduled
					Account.add(new_transaction.account, new_transaction.account_currency_amount, new_transaction.local_datetime)
				end
			end
		end
	
		def update_transactions(transaction, params, user)
			# ensure the transaction is the main one (no child, outgoing if transfer)
			transaction = Transaction.find_main_transaction(transaction)

			# destroy existing child transactions
			destroy_children(transaction)

			# get the new parameters
			transaction_params = Transaction.create(params, user, save: false)

			# update the parent transaction(s)
			transaction_params = prepare_transaction_params(transaction, transaction_params, user)

			# update the main transactions
			transaction.update!(transaction_params[:main])
			transaction = user.transactions.find(transaction.id)
			transaction.transfer_transaction.update!(transaction_params[:transfer]) unless transaction.transfer_transaction.nil?

			transaction_params[:children_main].each do |child|
				create_child(transaction, child)
			end
			transaction_params[:children_transfer].each do |child|
				create_child(transaction.transfer_transaction, child)
			end

			return user.transactions.find(transaction.id)

		end

		def create_child(transaction, params)
			transaction.children.new(params)
			transaction.save!
		end

		# destroy child transactions
		def destroy_children(transaction)
			transaction.children.destroy_all
			transaction.transfer_transaction.children.destroy_all unless transaction.transfer_transaction.nil?
		end

		# prepare the transaction parameters for the update
		def prepare_transaction_params(transaction, transaction_params, user)

			# prepare transfer transactions
			transfer_transaction = transaction.transfer_transaction
			if transaction_params[0][:transfer_transaction_id].nil?
				unless transaction.transfer_transaction.nil?
					# if no transfer transaction is in the new transaction, but the original transaction had one, destroy it
					transaction.transfer_transaction.destroy
				end
			else
				transaction_params[1][:transfer_transaction_id] = transaction.id
				transaction_params[1][:transfer_account_id] = transaction.account.id

				if transfer_transaction.nil?
					# if the new transaction has a transfer transaction, but the original transaction doesn't, instantiate it
					transfer_transaction = user.transactions.new(remove_fields(transaction_params[1]))
					transfer_transaction.user_id = user.id
					transfer_transaction.save!
				end
				transaction_params[0][:transfer_transaction_id] = transfer_transaction.id
				transaction_params[0][:transfer_account_id] = transfer_transaction.account.id

				children_transfer = transaction_params[1][:children]
			end

			children_transfer ||= []

			children_main = transaction_params[0][:children]
			children_main ||= []

			transaction_params = remove_fields(transaction_params)
			children_main = remove_fields(children_main)
			children_transfer = remove_fields(children_transfer)

			return {
				main: transaction_params[0],
				transfer: transaction_params[1],
				children_main: children_main,
				children_transfer: children_transfer
			}
		end

		# remove fields that should not be updated
		def remove_fields(params)
			return if params.nil?
			if params.class == Array
				params.each do |p|
					p = remove_fields_from_hash(p)
				end
			else
				params = remove_fields_from_hash(params)
			end

			return params
		end

		def remove_fields_from_hash(params)
			params.delete(:children)
			params.delete(:schedule_id)
			params.delete(:schedule_period_id)
			params.delete(:scheduled_transaction_id)

			if @scheduled
				params.delete(:account_currency_amount)
				params.delete(:user_currency_amount)
			end

			return params
		end


  end
end