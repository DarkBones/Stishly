class AddColToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_real, :boolean, :default => 1
  end
end
