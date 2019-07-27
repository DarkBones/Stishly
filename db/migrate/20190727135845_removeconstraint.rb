class Removeconstraint < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :currency, :string, :null => true
  end
end
