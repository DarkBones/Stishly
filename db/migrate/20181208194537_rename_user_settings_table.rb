class RenameUserSettingsTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :user_settings, :setting_values
  end
end
