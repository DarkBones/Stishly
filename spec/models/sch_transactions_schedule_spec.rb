# == Schema Information
#
# Table name: sch_transactions_schedules
#
#  id                 :bigint(8)        not null, primary key
#  sch_transaction_id :bigint(8)
#  schedule_id        :bigint(8)
#

require 'rails_helper'

RSpec.describe SchTransactionsSchedule, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
