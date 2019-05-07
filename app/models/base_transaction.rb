# == Schema Information
#
# Table name: base_transactions
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BaseTransaction < ApplicationRecord
end
