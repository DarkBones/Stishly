class AddSlugToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :slug, :string
    add_index :accounts, :slug, unique: false
  end
end
