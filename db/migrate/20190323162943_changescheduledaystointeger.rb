class Changescheduledaystointeger < ActiveRecord::Migration[5.2]
  def change
    #change_column :schedules, :days_month_day, :integer
    execute <<-SQL
      ALTER TABLE schedules ALTER COLUMN days_month_day TYPE integer USING (trim(days_month_day)::integer);
    SQL
  end
end
