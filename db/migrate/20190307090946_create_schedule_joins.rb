class CreateScheduleJoins < ActiveRecord::Migration[5.2]
  def change
    create_table :schedule_joins do |t|
      t.references :transaction
      t.references :schedule
    end
  end
end
