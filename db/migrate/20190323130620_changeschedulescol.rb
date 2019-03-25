class Changeschedulescol < ActiveRecord::Migration[5.2]
  def change
    #change_column :schedules, :exclusion_met_day, :integer
    execute <<-SQL
      ALTER TABLE schedules ALTER COLUMN exclusion_met_day TYPE integer USING (trim(exclusion_met_day)::integer);
    SQL
  end
end
