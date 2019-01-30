class CreateAccountHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :account_histories do |t|
      t.references :account_id
      t.datetime :local_datetime
      t.integer :balance
      t.timestamps
    end
  end
end
