class CreateUserSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_settings do |t|
      t.references :user
      t.references :settings
      t.string :value
      t.timestamps
    end
  end
end
