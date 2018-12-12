# == Schema Information
#
# Table name: transactions
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)
#  amount         :integer
#  direction      :integer
#  description    :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :integer
#  timezone       :string(255)
#  local_datetime :datetime
#  currency       :string(255)
#

class Transaction < ApplicationRecord
  belongs_to :account
  has_one :user, through: :account

  def self.create_from_string(params, current_user)
    transaction = CreateFromString.new(params, current_user).perform
  end

  def self.create(account_id, params, current_user)
    account_currency = Account.get_currency(account_id, current_user)

    if account_currency.iso_code != params[:currency]
      params[:account_currency_amount] = CurrencyRate.convert(params[:amount], Money::Currency.new(params[:currency]), account_currency)
    else
      params[:account_currency_amount] = params[:amount]
    end

    transaction = current_user.transactions.new(params)
    transaction.save

    Account.add(account_id, params[:amount])
  end
end
