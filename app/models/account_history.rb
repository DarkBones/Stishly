# == Schema Information
#
# Table name: account_histories
#
#  id             :bigint           not null, primary key
#  account_id     :bigint
#  local_datetime :datetime
#  balance        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class AccountHistory < ApplicationRecord
  belongs_to :account

  def self.historic_balance(account, datetime)
    history = account.account_histories.order(:local_datetime).reverse_order().where("local_datetime < ?", datetime).take()
    if history
      return history.balance
    else
      return 0
    end
  end

end
