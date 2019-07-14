class AddMaxFixedExpensesToSubscriptionTiers < ActiveRecord::Migration[5.2]
  def change
  	add_column :subscription_tiers, :max_fixed_expenses, :integer, default: 10
  	add_column :schedules, :type, :string, default: "schedule"
  end
end
