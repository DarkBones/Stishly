class SchedulesTransaction < ApplicationRecord
  has_many :transactions
  has_many :schedules

  def self.join_transactions(params, current_user)
    schedule = current_user.schedules.where(id: params[:schedules]).take

    transactions = params[:transactions].split
    transactions.each do |t|
      transaction = current_user.transactions.where(id: t).take

      previous_join = transaction.schedules.where(id: schedule.id).take

      unless transaction.nil?
        if previous_join.nil?
          transaction.schedules << schedule
        end
      end
    end
  end


end
