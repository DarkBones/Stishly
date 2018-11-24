class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.references :user
      t.references :transaction
      t.references :account
      t.date :start_date
      t.date :end_date
      t.string :period # monthly, weekly, daily, etc
      t.integer :period_day # x'th of the week / month / etc
      t.integer :period_occurences # every x months / weeks / days / etc
      t.string :exception_days # if day is x'th of period, don't process
      t.string :exception_rule # if exception is met, run this instead
      t.date :next_occurrence # when the transaction will occur next
      t.timestamps
    end
  end
end
