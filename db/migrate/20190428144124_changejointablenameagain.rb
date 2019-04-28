class Changejointablenameagain < ActiveRecord::Migration[5.2]
  def change
    rename_table :scheduled_transactions, :sch_transactions
  end
end
