class CreateScheduledTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :scheduled_transactions do |t|
      t.references :user
      t.integer :amount
      t.integer :direction
      t.string :description
      t.references :account
      t.string :currency
      t.references :category
      t.references :parent
      t.integer :transfer_account_id
      t.timestamps
    end
  end
end
