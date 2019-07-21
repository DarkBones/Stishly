class AddEmailEncToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :email_enc, :binary
  	add_index :users, :email_enc
  end
end
