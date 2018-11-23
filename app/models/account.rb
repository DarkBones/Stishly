# == Schema Information
#
# Table name: accounts
#
#  id          :bigint(8)        not null, primary key
#  balance     :integer
#  currency_id :bigint(8)
#  user_id     :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#  description :string(255)
#

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions

  def self.create_from_string(str, user_id, cents_amount)
    reg = ".+\s+[\.,]*[0-9\.\s]+$"
    @name_balance = str.to_s.strip

    if /#{reg}/.match(@name_balance)
      @name_balance = @name_balance.split

      @name = @name_balance[0..-2].join(' ')

      cents_amount > 0 ? @balance = (@name_balance[-1].sub(",", ".").to_f * cents_amount).to_i : @balance = @name_balance[-1].to_i

      self.create(:user_id => user_id, :name => @name, :balance => @balance)
    elsif @name_balance.length > 0
      self.create(:user_id => user_id, :name => @name_balance, :balance => 0)
    end
  end
end
