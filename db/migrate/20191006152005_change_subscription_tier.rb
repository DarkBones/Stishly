class ChangeSubscriptionTier < ActiveRecord::Migration[5.2]
  def change
  	drop_table :subscription_tiers
  	remove_column :users, :subscription_tier_id
  	add_column :users, :subscription, :string, default: 'free'
  end
end
