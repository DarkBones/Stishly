class IsDisabled < ActiveRecord::Migration[5.2]
  def change
  	add_column :accounts, :is_disabled, :boolean, default: false
  end
end
