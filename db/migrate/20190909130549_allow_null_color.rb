class AllowNullColor < ActiveRecord::Migration[5.2]
  def change
  	change_column :categories, :color, :string, :null => true
  end
end
