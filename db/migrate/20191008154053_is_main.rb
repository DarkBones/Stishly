class IsMain < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :is_main, :boolean
  end
end
