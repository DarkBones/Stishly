# == Schema Information
#
# Table name: transactions
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)
#  amount      :integer
#  direction   :integer
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Transaction < ApplicationRecord
  belongs_to :account
  has_one :user, through: :account

  def self.create_from_string(str, current_user, account_id, direction)
    # TODO: Store the transaction's timezone

    reg = ".+\s+[\.,]*-?[0-9\.]+$"
    @name_amount = str.to_s.strip
    @cents_amount = current_user.country.currency.number_to_basic

    if /#{reg}/.match(@name_amount)
      @name_amount = @name_amount.split

      @name = @name_amount[0..-2].join(' ')

      if @cents_amount > 0
        @amount = (@name_amount[-1].sub(",", ".").to_f * @cents_amount).to_i
      else
        @amount = @name_amount[-1].to_i
      end

      @amount *= direction

      self.create(:user_id => current_user.id, :description => @name, :amount => @amount, :direction => direction, :account_id => account_id, :timezone => current_user.timezone)
      Account.add(account_id, @amount)
      return 200
    else
      return 500
    end
  end
end
