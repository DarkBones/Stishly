# == Schema Information
#
# Table name: countries
#
#  id          :bigint(8)        not null, primary key
#  name        :string(255)
#  currency_id :bigint(8)
#  date_format :string(255)
#  week_start  :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Country < ApplicationRecord
  belongs_to :currency
  has_many :users
end
