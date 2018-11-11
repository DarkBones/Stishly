class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :balance
      t.references :currency
      t.references :user
      t.timestamps
    end
  end
end
