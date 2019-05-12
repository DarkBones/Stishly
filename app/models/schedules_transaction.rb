# == Schema Information
#
# Table name: schedules_transactions
#
#  id             :bigint(8)        not null, primary key
#  schedule_id    :bigint(8)
#  transaction_id :bigint(8)
#

class SchedulesTransaction < ApplicationRecord

  before_save

  def self.join_transactions(params, current_user)
    schedule = current_user.schedules.find(params[:schedules])
    
    return if schedule.nil?

    transaction_ids = params[:transactions].split
    transaction_ids.each do |t_id|
      transaction = current_user.transactions.find(t_id)

      next if transaction.nil?

      link = transaction.schedules << schedule
    end

  end

end
