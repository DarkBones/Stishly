class EncryptPii < ActiveRecord::Migration[5.2]
  def change
  	rename_column :users, :first_name, :first_name_enc
  	#change_column :users, :first_name_enc, :text

  	rename_column :users, :last_name, :last_name_enc
  	#change_column :users, :last_name_enc, :text

  	rename_column :users, :email, :email_enc
  	#change_column :users, :email_enc, :text
  end
end
