class Schedule
	class RunScheduledTransactions

		def initialize(transactions)
			date = Time.now.utc.to_date

			@transactions = transactions
			@transactions ||= Transaction.where("scheduled_date <= ? AND is_scheduled = true", date)
		end

		def perform
			transactions = []
			@transactions.each do |transaction|
				transactions.push(run_transaction(transaction)) if transaction.is_scheduled
			end

			return transactions
		end

private

		def run_transaction(transaction)
			return unless transaction.is_scheduled

			transaction.scheduled_date = nil
			transaction.is_scheduled = false
			transaction.save!

			Account.add(transaction.user, transaction.account, transaction.account_currency_amount, transaction.local_datetime)

			return transaction
		end

	end
end