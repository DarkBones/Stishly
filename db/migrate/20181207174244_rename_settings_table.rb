class RenameSettingsTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :user_settings, :settings_id, :setting_id
  end
end
