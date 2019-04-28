class Renametransactions < ActiveRecord::Migration[5.2]
  def change
    rename_column :schedules_transactions, :transaction_id, :scheduled_transaction_id
  end
end
