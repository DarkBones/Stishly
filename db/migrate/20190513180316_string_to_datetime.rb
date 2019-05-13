class StringToDatetime < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :local_datetime, :datetime
  end
end
