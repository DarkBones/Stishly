# == Schema Information
#
# Table name: schedules_transactions
#
#  id             :bigint(8)        not null, primary key
#  schedule_id    :bigint(8)
#  transaction_id :bigint(8)
#  original_link  :boolean
#

class SchedulesTransaction < ApplicationRecord

  def self.join_transactions(params, current_user)

  end

end
