class EmailNull < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :email_enc, :string, :null => true
  end
end
