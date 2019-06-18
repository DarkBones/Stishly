class ChangeReadToIsRead < ActiveRecord::Migration[5.2]
  def change
  	rename_column :messages, :read, :is_read
  end
end
