class ChangeCountriesTable < ActiveRecord::Migration[5.2]
  def change
    change_column :countries, :week_start, :integer
    remove_column :countries, :currency_id
  end
end
