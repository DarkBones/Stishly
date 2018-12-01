# == Schema Information
#
# Table name: schedules
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  transaction_id    :bigint(8)
#  account_id        :bigint(8)
#  start_date        :date
#  end_date          :date
#  period            :string(255)
#  period_day        :integer
#  period_occurences :integer
#  exception_days    :string(255)
#  exception_rule    :string(255)
#  next_occurrence   :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Schedule < ApplicationRecord
  belongs_to :transactions, optional: true
end
