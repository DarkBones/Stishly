class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_one :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  def self.get_user_categories(current_user, as_array=false)
    
    if as_array
      main_categories = current_user.categories.where(:parent_id => nil)

      array = []
      main_categories.each do |main|
        array.push(main.name)

        children = get_child_categories(main)

        #array.push(children)

        children.each do |child|
          array.push("_" + child.name)
        end

        break

        #sub_categories = main.children
        #sub_categories.each do |sub|
        #  array.push("_" + sub.name)
        #end

      end

      return array
    else
      return current_user.categories
    end

  end

  private

  def self.get_child_categories(category, children_array = [])
    children = category.children

    children.each do |child|
      children_array.push(child)
      children_array = get_child_categories(child, children_array)
    end
    children_array
  end

  def self.get_child_categories_OLD(category, categories=[])
    if category.children.length > 0
      category.children.each do |c|
        categories.push(c.name)
        return get_child_categories(c, categories)
      end
    else
      return categories
    end
  end
end
