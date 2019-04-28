class Renamejoinstable < ActiveRecord::Migration[5.2]
  def change
    rename_table :schedule_joins, :schedules_transactions
  end
end
