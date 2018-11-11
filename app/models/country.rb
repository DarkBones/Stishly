class Country < ApplicationRecord
  has_many :users
  belongs_to :currency
end
