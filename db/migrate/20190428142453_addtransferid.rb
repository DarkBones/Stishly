class Addtransferid < ActiveRecord::Migration[5.2]
  def change
    add_column :scheduled_transactions, :original_transaction_id, :integer, index: true
  end
end
