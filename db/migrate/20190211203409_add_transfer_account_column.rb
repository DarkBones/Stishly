class AddTransferAccountColumn < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :transfer_account, index: true
  end
end
