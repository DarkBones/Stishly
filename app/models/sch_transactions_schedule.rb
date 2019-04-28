class SchTransactionsSchedule < ApplicationRecord
  has_many :sch_transactions
  has_many :schedules

  def self.join_transactions(params, current_user)
    schedule = current_user.schedules.where(id: params[:schedules]).take

    transactions = params[:transactions].split
    transactions.each do |t|
      transaction = current_user.transactions.where(id: t).take

      #previous_join = transaction.schedules.where(id: schedule.id).take

      unless transaction.nil?

        scheduled_transactions = SchTransaction.create_from_transaction(transaction, current_user)

        scheduled_transactions.each do |st|
          previous_join = st.schedules.where(id: schedule.id).take

          if previous_join.nil?
            st.schedules << schedule
          end

        end

      end

    end

  end
end
