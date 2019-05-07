class CreateScheduleTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :schedule_transactions do |t|

      t.timestamps
    end
  end
end
