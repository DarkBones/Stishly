# == Schema Information
#
# Table name: schedules_transactions
#
#  id             :bigint           not null, primary key
#  schedule_id    :bigint
#  transaction_id :bigint
#

class SchedulesTransaction < ApplicationRecord

  before_save

  def self.join_transactions(params, current_user)
    schedule = current_user.schedules.find(params[:schedules])
    return if schedule.nil?

    transaction_ids = params[:transactions].split

    main_transactions = []
    transactions = []
    transaction_ids.each do |t_id|
      t = current_user.transactions.find(t_id)
      next if t.nil?

      t = Transaction.find_main_transaction(t)

      next if main_transactions.include? t.id

      main_transactions.push(t.id)

      sch_transactions = Transaction.create_scheduled_transactions(t, current_user)
      transactions.push(Transaction.join_to_schedule(sch_transactions, schedule))
    end

    return transactions
  end

end
