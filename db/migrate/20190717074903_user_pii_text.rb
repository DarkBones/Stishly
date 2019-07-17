class UserPiiText < ActiveRecord::Migration[5.2]
  def change
  	change_column_default(:users, :email_enc, nil)

  	#change_column :users, :first_name_enc, :text
  	#change_column :users, :last_name_enc, :text
  	#change_column :users, :email_enc, :text
  end
end
