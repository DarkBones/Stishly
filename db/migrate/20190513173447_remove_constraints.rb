class RemoveConstraints < ActiveRecord::Migration[5.2]
  def change
    drop_table :base_transactions

    change_column :schedules, :name, :string, :null => true
    change_column :schedules, :start_date, :date, :null => true
    change_column :schedules, :period, :string, :null => true
    change_column :schedules, :timezone, :string, :null => true

    change_column :transactions, :timezone, :string, :null => true
    change_column :transactions, :local_datetime, :string, :null => true
    change_column :transactions, :account_currency_amount, :integer, :null => true
  end
end
