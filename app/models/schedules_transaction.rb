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

  def self.join_transactions_OLD(params, current_user)
    schedule = current_user.schedules.find(params[:schedules])
    
    return if schedule.nil?

    transaction_ids = params[:transactions].split
    transaction_ids.each do |t_id|
      original_transaction = current_user.transactions.find(t_id)

      next if original_transaction.nil?

      transaction = original_transaction.dup

      #transaction = current_user.transaction.find(transaction.id)
      transaction.is_scheduled = true
      transaction.save

      link = transaction.schedules << schedule
    end

  end

  def self.join_transactions(params, current_user)
    schedule = current_user.schedules.find(params[:schedules])
    return if schedule.nil?

    transaction_ids = params[:transactions].split

    transactions = []
    transaction_ids.each do |t_id|
      add = true
      t = current_user.transactions.find(t_id)

      next if t.nil?

      add = t.parent_id.nil?

      next unless add

      transactions.each do |trx|
        add = false if trx.transfer_transaction_id == t.id
      end

      puts "ADD = #{add}"

      transactions.push(t) if add

    end

    puts transactions.length
    puts "/////////////////////////"

    transactions.each do |t|
      #transaction = current_user.transactions.find(t)

      #next if transaction.nil?

      scheduled_transactions = Transaction.create_scheduled_transactions(t, current_user)
      scheduled_transactions.each do |st|
        st.schedules << schedule
      end
    end
  end

end
