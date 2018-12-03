class ChangeCountryCodeType < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :country_code, :string
  end
end
