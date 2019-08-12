class RemoveLastOccurrenceFromSchedules < ActiveRecord::Migration[5.2]
  def change
  	remove_column :schedules, :last_occurrence
  end
end
