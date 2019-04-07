class AddUserCurrency < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :currency, :string, null: false
    add_column :transactions, :user_currency_amount, :int, null: false
  end
end
