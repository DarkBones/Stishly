class AddScheduleDatedToTransactions < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :scheduled_date, :date
  end
end
