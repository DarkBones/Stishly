# == Schema Information
#
# Table name: schedules_transactions
#
#  id             :bigint(8)        not null, primary key
#  transaction_id :bigint(8)
#  schedule_id    :bigint(8)
#

require 'rails_helper'

RSpec.describe SchedulesTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
