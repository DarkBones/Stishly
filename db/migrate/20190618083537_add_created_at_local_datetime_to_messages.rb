class AddCreatedAtLocalDatetimeToMessages < ActiveRecord::Migration[5.2]
  def change
  	add_column :messages, :created_at_local_datetime, :datetime
  end
end
