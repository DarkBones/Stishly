class AddLocaldatetime < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :local_datetime, :datetime
  end
end
