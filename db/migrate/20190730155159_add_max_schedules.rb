class AddMaxSchedules < ActiveRecord::Migration[5.2]
  def change
  	add_column :subscription_tiers, :max_schedules, :integer, :default => 3
  end
end
