class AddIsBalancerColumn < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :is_balancer, :boolean, default: false
  end
end
