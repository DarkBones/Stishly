class ChangeMessagesToNoticiations < ActiveRecord::Migration[5.2]
  def change
  	rename_table :messages, :notifications
  end
end
