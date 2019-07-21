# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  color      :string(255)      not null
#  symbol     :string(255)
#  user_id    :bigint
#  parent_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
