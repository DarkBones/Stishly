class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :date_format
      t.integer :week_start
      t.timestamps
    end
  end
end
