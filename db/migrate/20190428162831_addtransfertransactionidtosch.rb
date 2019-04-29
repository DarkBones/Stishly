class Addtransfertransactionidtosch < ActiveRecord::Migration[5.2]
  def change
    add_column :sch_transactions, :transfer_transaction_id, :integer
  end
end
