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

    transactions = []
    transaction_ids.each do |t_id|
      add = true
      t = current_user.transactions.find(t_id)

      next if t.nil? || (!t.transfer_transaction_id.nil? && t.direction == 1)

      add = t.parent_id.nil?

      next unless add

      transactions.each do |trx|
        add = false if trx.transfer_transaction_id == t.id
      end

      transactions.push(t) if add

    end

    transactions.each do |t|
      scheduled_transactions = Transaction.create_scheduled_transactions(t, current_user)
      scheduled_transactions.each do |st|
        Transaction.join_to_schedule(st, schedule)
      end

    end
  end

end
