class Country < ApplicationRecord
  belongs_to :currency
  has_many :users
end
