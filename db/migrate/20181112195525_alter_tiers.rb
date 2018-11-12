class AlterTiers < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_tiers do |t|
      t.string :name
      t.integer :cost
      t.integer :month_billing_cycle
      t.timestamps
    end
  end
end
