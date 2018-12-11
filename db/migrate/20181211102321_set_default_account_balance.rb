class SetDefaultAccountBalance < ActiveRecord::Migration[5.2]
  def change
    change_column :accounts, :balance, :integer, default: 0
  end
end
