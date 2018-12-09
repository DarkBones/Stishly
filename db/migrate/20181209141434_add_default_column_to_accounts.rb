class AddDefaultColumnToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_default, :boolean
  end
end
