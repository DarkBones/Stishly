class Addtransfertransactionid < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :transfer_transaction_id, :integer
  end
end
