class CreateCurrencyRateUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_rate_updates do |t|
    	t.string :currency
      t.timestamps
    end
  end
end
