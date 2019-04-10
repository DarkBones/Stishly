class Remove < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :is_real
  end
end
