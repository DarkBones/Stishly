class CreateSchedulesTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules_transactions do |t|
      t.references :schedule
      t.references :transaction
      t.boolean :original_link
    end
  end
end
