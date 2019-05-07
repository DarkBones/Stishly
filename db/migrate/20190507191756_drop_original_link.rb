class DropOriginalLink < ActiveRecord::Migration[5.2]
  def change
    remove_column :schedules_transactions, :original_link
  end
end
