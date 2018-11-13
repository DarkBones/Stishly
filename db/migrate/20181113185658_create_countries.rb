class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :name
      t.references :currency
      t.string :date_format
      t.string :week_start
      t.timestamps
    end
  end
end
