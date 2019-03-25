class AddNextOccurrenceToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :next_occurrence, :date
  end
end
