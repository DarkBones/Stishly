class ChangeAccountType < ActiveRecord::Migration[5.2]
  def change
  	rename_column :accounts, :is_spending, :account_type
  	change_column :accounts, :account_type, :string, :default => "spend"
  	remove_column :accounts, :is_saving
  end
end
