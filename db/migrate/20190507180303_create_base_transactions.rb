class CreateBaseTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :base_transactions do |t|

      t.timestamps
    end
  end
end
