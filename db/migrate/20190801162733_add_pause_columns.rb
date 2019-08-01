class AddPauseColumns < ActiveRecord::Migration[5.2]
  def change
  	add_column :schedules, :pause_until, :date
  	add_column :schedules, :pause_until_utc, :datetime
  end
end
