class RenameEncryptedEmailToUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_index :users, :encrypted_email_bidx
  	rename_column :users, :encrypted_email_bidx, :email_bidx
  	add_index :users, :email_bidx
  end
end
