# == Schema Information
#
# Table name: scheduled_transactions
#
#  id                  :bigint(8)        not null, primary key
#  user_id             :bigint(8)
#  amount              :integer
#  direction           :integer
#  description         :string(255)
#  account_id          :bigint(8)
#  currency            :string(255)
#  category_id         :bigint(8)
#  parent_id           :bigint(8)
#  transfer_account_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

RSpec.describe ScheduledTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
