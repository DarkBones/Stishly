class AddScheduleToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :schedule, foreign_key: true
  end
end
