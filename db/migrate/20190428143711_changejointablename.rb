class Changejointablename < ActiveRecord::Migration[5.2]
  def change
    rename_table :scheduled_transactions_schedules, :schedules_transactions
  end
end
