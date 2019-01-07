class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :transactions, :account_id
    add_index :accounts, :name
  end
end
