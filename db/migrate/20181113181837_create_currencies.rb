class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :symbol
      t.string :iso_code
      t.integer :number_to_basic
      t.timestamps
    end
  end
end
