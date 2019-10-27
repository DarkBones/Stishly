class AddPositionToPosts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :posts, :description
    add_column :posts, :position, :integer
  end
end
