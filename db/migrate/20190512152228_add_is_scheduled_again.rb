class AddIsScheduledAgain < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :is_scheduled, :boolean, default: false
  end
end
