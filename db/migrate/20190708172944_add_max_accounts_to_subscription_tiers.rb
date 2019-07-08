class AddMaxAccountsToSubscriptionTiers < ActiveRecord::Migration[5.2]
  def change
  	add_column :subscription_tiers, :max_accounts, :integer, default: 3
  end
end
