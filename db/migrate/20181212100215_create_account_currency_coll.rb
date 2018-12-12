class CreateAccountCurrencyColl < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :account_currency_amount, :integer
  end
end
