class Userstablecountries < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :country, index: true
  end
end
