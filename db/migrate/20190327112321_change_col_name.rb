class ChangeColName < ActiveRecord::Migration[5.2]
  def change
    rename_column :schedules, :next_occurrenct_gmt, :next_occurrence_utc
  end
end
