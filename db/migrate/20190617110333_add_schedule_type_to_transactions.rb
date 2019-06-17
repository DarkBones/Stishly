class AddScheduleTypeToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :queue_scheduled, :boolean, :default => false
    add_column :transactions, :is_queued, :boolean, :default => false
  end
end
