class AlterUsersDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :subscription_tier_id, 0
  end
end
