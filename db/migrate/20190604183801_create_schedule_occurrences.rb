class CreateScheduleOccurrences < ActiveRecord::Migration[5.2]
  def change
    create_table :schedule_occurrences do |t|
      t.references :schedule
      t.date :occurrence_local_datetime
      t.timestamps
    end
  end
end
