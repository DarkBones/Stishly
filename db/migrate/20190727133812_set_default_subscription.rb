class SetDefaultSubscription < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :subscription_tier_id, :bigint, :default => 0
  end
end
