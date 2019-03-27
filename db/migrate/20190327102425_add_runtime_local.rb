class AddRuntimeLocal < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :next_occurrenct_gmt, :datetime
  end
end
