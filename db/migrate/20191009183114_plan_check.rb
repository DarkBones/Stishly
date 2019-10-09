class PlanCheck < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :last_plan_check, :datetime
  end
end
