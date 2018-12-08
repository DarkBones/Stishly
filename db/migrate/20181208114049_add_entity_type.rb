class AddEntityType < ActiveRecord::Migration[5.2]
  def change
    add_column :user_settings, :entity_type, :string
  end
end
