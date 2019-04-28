class ScheduleJoin < ApplicationRecord
  has_many :transactions
  has_many :schedules

  def self.join_transactions(params, current_user)
    puts params.to_yaml
    #params = params[:schedule_join]

    schedule = current_user.schedules.where(id: params[:schedules]).take

    transactions = params[:transactions].split

    transactions.each do |t|
      transaction = current_user.transactions.where(id: t).take

      #schedule.schedule_joins << transaction unless transaction.nil?
      previous_join = ScheduleJoin.where(schedule_id: schedule.id, transaction_id: transaction.id).take

      unless transaction.nil?
        if previous_join.nil?
          join = ScheduleJoin.new({schedule_id: schedule.id, transaction_id: transaction.id})
          join.save
        end
      end
    end
  end


end
