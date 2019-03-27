class AddNameIndexOnSchedules < ActiveRecord::Migration[5.2]
  def change
    add_index :schedules, :name
  end
end
