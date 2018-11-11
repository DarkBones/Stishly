class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :user
      t.integer :amount
      t.integer :direction
      t.string :description
      t.timestamps
    end
  end
end
