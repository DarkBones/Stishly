class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, through: :categories
  has_one :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'
end
