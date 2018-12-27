class AddCategoryId < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :category, index: true
  end
end
