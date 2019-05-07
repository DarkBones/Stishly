class RenameSchTransactionsTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :sch_transactions_schedules, :schedules_transactions
    drop_table :sch_transactions
  end
end
