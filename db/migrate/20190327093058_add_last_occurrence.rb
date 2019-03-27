class AddLastOccurrence < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :last_occurrence, :date
  end
end
