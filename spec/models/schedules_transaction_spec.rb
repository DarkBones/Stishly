# == Schema Information
#
# Table name: schedules_transactions
#
#  id             :bigint(8)        not null, primary key
#  schedule_id    :bigint(8)
#  transaction_id :bigint(8)
#  original_link  :boolean
#

require 'rails_helper'

RSpec.describe SchedulesTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
