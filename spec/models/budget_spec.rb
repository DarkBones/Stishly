# == Schema Information
#
# Table name: budgets
#
#  id          :bigint           not null, primary key
#  user_id     :bigint
#  category_id :bigint
#  amount      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  hash_id     :string(255)
#

require 'rails_helper'

RSpec.describe Budget, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
