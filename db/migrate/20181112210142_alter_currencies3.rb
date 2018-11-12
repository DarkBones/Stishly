class AlterCurrencies3 < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :symbol
      t.integer :decimal_places
      t.string :iso_code
      t.timestamps
    end
  end
end
