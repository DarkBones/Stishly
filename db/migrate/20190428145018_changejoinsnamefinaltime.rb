class Changejoinsnamefinaltime < ActiveRecord::Migration[5.2]
  def change
    rename_table :schedules_transactions, :sch_transactions_schedules
  end
end
