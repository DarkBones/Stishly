class RenameIsScheduled < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :is_scheduled
    add_column :transactions, :scheduled_transaction_id, :integer, index: true
  end
end
