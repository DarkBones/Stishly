class AddFinishedSetupToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :finished_setup, :boolean, default: false
  end
end
