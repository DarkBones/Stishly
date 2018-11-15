class AlterAccounts < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      t.string :name
      t.string :description
    end
  end
end
