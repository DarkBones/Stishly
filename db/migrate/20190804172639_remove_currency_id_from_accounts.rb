class RemoveCurrencyIdFromAccounts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :accounts, :currency_id
  end
end
