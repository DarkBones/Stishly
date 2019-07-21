# == Schema Information
#
# Table name: schedules_transactions
#
#  id             :bigint           not null, primary key
#  schedule_id    :bigint
#  transaction_id :bigint
#

require 'rails_helper'

RSpec.describe SchedulesTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
