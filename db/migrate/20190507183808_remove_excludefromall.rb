class RemoveExcludefromall < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :exclude_from_all
  end
end
