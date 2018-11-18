class AddPositionToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :position, :integer
  end
end
