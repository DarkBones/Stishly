class AlertTypeColumn < ActiveRecord::Migration[5.2]
  def change
  	rename_column :schedules, :type, :type_of
  end
end
