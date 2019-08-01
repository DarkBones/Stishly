class AddPeriodIdToSchedulesAndTransactions < ActiveRecord::Migration[5.2]
  def change
  	add_column :schedules, :current_period_id, :int, :default => 0
  	add_column :transactions, :schedule_period_id, :int
  end
end
