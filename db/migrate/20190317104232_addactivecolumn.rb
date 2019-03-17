class Addactivecolumn < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :is_active, :boolean, :default => 1
  end
end
