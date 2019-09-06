class AddHashIdToModels < ActiveRecord::Migration[5.2]
  def change
  	add_column :accounts, :hash_id, :string, index: true
  	add_column :categories, :hash_id, :string, index: true
  	add_column :schedules, :hash_id, :string, index: true
  	add_column :transactions, :hash_id, :string, index: true
  	add_column :notifications, :hash_id, :string, index: true
  	add_column :users, :hash_id, :string, index: true
  end
end
