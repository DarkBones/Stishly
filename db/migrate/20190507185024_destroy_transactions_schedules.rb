class DestroyTransactionsSchedules < ActiveRecord::Migration[5.2]
  def change
    drop_table :schedules_transactions
  end
end
