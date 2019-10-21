# == Schema Information
#
# Table name: daily_budgets
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  spent      :integer
#  amount     :integer
#  currency   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  local_date :date
#

require 'rails_helper'

RSpec.describe DailyBudget, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
