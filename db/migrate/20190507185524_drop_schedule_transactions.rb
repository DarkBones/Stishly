class DropScheduleTransactions < ActiveRecord::Migration[5.2]
  def change
    drop_table :schedule_transactions
  end
end
