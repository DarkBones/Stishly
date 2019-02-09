class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_one :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  def self.get_user_categories(current_user, as_array=false, use_levels=false)
    
    if as_array
      main_categories = current_user.categories.where(:parent_id => nil)

      array = []
      main_categories.each do |main|

        if use_levels
          array.push({level: 0, category: main})
        else
          array.push(main)
        end

        children = get_child_categories(main)

        children.each do |child|
          if use_levels
            array.push({level: child[:level], category: child[:category]})
          else
            array.push(child[:category])
          end
        end

      end

      return array
    else
      return current_user.categories
    end

  end

  private

  def self.get_child_categories(category, children_array = [], level = 0)
    children = category.children

    level += 1

    children.each do |child|
      children_array.push({level: level, category: child})
      children_array = get_child_categories(child, children_array, level)
    end
    children_array
  end
end
