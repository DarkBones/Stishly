class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.references :subscription_tier
      t.references :country
      t.timestamps
    end

    change_column_default :users, :subscription_tier_id, 1
  end
end
