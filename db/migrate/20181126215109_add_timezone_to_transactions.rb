class AddTimezoneToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :timezone, :string
  end
end
