class CreateScheduleOccurrences < ActiveRecord::Migration[5.2]
  def change
    create_table :schedule_occurrences do |t|
      t.references :schedule
      t.datetime :occurrence_utc
      t.datetime :occurrence_local
    end
  end
end
