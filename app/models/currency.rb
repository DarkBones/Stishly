# == Schema Information
#
# Table name: currencies
#
#  id              :bigint(8)        not null, primary key
#  name            :string(255)
#  symbol          :string(255)
#  iso_code        :string(255)
#  number_to_basic :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Currency < ApplicationRecord
  has_many :countries
end
