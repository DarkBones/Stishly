class ChangeUserIDcolumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :user_settings, :user_id, :entity_id
  end
end
