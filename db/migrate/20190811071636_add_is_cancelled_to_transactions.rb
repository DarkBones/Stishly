class AddIsCancelledToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :is_cancelled, :boolean
  end
end
