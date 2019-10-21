class AddSlugToPosts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :posts, :hash_id
    add_column :posts, :slug, :string
    add_index :posts, :slug, unique: true
  end
end
