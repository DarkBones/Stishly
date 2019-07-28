class SetDefaultTimezone < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :timezone, :string, :default => "Europe/London"
  end
end
