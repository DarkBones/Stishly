class Renamejoinscol < ActiveRecord::Migration[5.2]
  def change
    rename_column :sch_transactions_schedules, :scheduled_transaction_id, :sch_transaction_id
  end
end
