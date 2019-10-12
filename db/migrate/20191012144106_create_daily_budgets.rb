class CreateDailyBudgets < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_budgets do |t|
    	t.references :user
    	t.integer :spent
    	t.integer :amount
    	t.string :currency
      t.timestamps
    end
  end
end
