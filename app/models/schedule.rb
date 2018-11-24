class Schedule < ApplicationRecord
  belongs_to :transactions, optional: true
end
