class AddCurrencyColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :currency, :string
    add_column :transactions, :currency, :string
  end
end
