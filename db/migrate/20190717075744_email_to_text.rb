class EmailToText < ActiveRecord::Migration[5.2]
  def change
  	remove_index "users", name: "index_users_on_email_enc"
  	change_column :users, :email_enc, :text
  end
end
