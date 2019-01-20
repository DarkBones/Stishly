class ChangeIsHiddenColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :is_hidden, :exclude_from_all
  end
end
