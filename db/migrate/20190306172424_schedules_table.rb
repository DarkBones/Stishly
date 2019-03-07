class SchedulesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :schedules

    create_table :schedules do |t|
      t.string :name
      t.references :user, index: true, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :period
      t.integer :period_num
      t.integer :days
      t.string :days_month
      t.string :days_month_day
      t.integer :days_exclude
      t.string :exclusion_met
      t.string :exclusion_met_day
      t.string :timezone
      t.timestamps
    end
  end
end
