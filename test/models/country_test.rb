# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  date_format  :string(255)
#  week_start   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_code :string(255)
#

require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
