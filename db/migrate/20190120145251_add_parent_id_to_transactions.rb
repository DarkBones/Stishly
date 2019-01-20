class AddParentIdToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :parent, index: true
    add_column :transactions, :is_hidden, :boolean, :default => 0
  end
end
