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

  def self.create_from_string(str, current_user)
    reg = ".+\s+[\.,]*[-0-9\.\s]+$"
    @name_balance = str.to_s.strip
    @cents_amount = current_user.country.currency.number_to_basic

    @balance = 0
    @name = @name_balance

    if /#{reg}/.match(@name_balance)
      @name_balance = @name_balance.split

      @name = @name_balance[0..-2].join(' ')

      if @cents_amount > 0
        @balance = (@name_balance[-1].sub(",", ".").to_f * @cents_amount).to_i
      else
        @balance = @name_balance[-1].to_i
      end
    end

    @existing_accounts = Account.where('user_id' => current_user.id, 'name' => @name)

    if @existing_accounts.length == 0
      self.create(:user_id => current_user.id, :name => @name, :balance => @balance)
    end
  end
end
