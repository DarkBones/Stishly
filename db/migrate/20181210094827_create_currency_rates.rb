class CreateCurrencyRates < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_rates do |t|
      t.string :from_currency
      t.string :to_currency
      t.float :rate
      t.integer :used_count
      t.timestamps
    end
  end
end
