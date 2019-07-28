class AddAccountTypes < ActiveRecord::Migration[5.2]
  def change
  	add_column :accounts, :is_spending, :boolean, :default => true
  	add_column :accounts, :is_saving, :boolean, :default => false

  	add_column :subscription_tiers, :max_spending_accounts, :integer, :default => 2
  end
end
