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

  def self.create_from_string(params, current_user)
    reg = ".+\s+[\.,]*-?[0-9\.]+$"
    
    name_balance = parse_string(params[:name_balance], current_user.country.currency.number_to_basic)

    create_account(name_balance, current_user)
  end

  def self.add(id, amount)
    @balance = Account.find_by_id(id).balance
    @balance += amount

    Account.update(id, :balance => @balance)
  end

  private

  def self.create_account(params, current_user)
    existing_accounts = current_user.accounts.where('name' => params[:name])

    if existing_accounts.length == 0
      account = current_user.accounts.build(params)
      account.save
    end
  end

  def self.parse_string(str, cents_amount)
    reg = ".+\s+[\.,]*-?[0-9\.]+$"
    name_balance = str.to_s.strip.split

    account_name = name_balance.join(' ')
    balance = 0

    if /#{reg}/.match(name_balance.join(' '))
      account_name = name = name_balance[0..-2].join(' ')

      if cents_amount > 0
        balance = (name_balance[-1].sub(",", ".").to_f * cents_amount).to_i
      else
        balance = @name_balance[-1].to_f.round.to_i
      end
    end

    result = {:name => account_name, :balance => balance}

  end
end
