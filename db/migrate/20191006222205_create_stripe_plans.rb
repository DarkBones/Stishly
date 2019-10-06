class CreateStripePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_plans do |t|
    	t.string :currency, index: true
    	t.integer :price_eur
    	t.integer :price_month
    	t.integer :price_year
    	t.string :plan_id_month
    	t.string :plan_id_year
      t.timestamps
    end
  end
end
