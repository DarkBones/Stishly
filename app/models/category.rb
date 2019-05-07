# == Schema Information
#
# Table name: categories
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  color      :string(255)      not null
#  symbol     :string(255)
#  user_id    :bigint(8)
#  parent_id  :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_one :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  def self.get_user_categories(current_user, as_array=false, include_blank=false)
    if as_array
      tree = Hash.new { |h,k| h[k] = { :name => nil, :children => [ ], :children_paths => "", :parent_id => nil } }

      idx = 0

      if include_blank
        tree[idx][:id] = ""
        tree[idx][:name] = "- any -"
        tree[idx][:color] = ""
        tree[idx][:symbol] = "any"
        tree[idx][:parent_id] = nil
        tree[idx][:children_paths] = ""

        tree[nil][:children].push(tree[idx])

        idx += 1
      end

      tree[idx][:id] = 0
      tree[idx][:name] = "Uncategorised"
      tree[idx][:color] = "0, 0%, 50%"
      tree[idx][:symbol] = "uncategorised"
      tree[idx][:parent_id] = nil
      tree[idx][:children_paths] = "uncategorised"

      tree[nil][:children].push(tree[idx])

      # set the parent_keys first (required for recursive search)
      current_user.categories.order(:name).each do |cat|
        tree[cat.id][:parent_id] = cat.parent_id
      end

      current_user.categories.order(:name).each do |cat|
        tree[cat.id][:id] = cat.id
        tree[cat.id][:name] = cat.name
        tree[cat.id][:color] = cat.color
        tree[cat.id][:symbol] = cat.symbol
        tree[cat.id][:children_paths] += ".#{cat.name}"
        #tree[cat.id][:parent_id] = cat.parent_id
        tree[cat.parent_id][:children].push(tree[cat.id])
        #tree[cat.parent_id][:children_paths] += ".#{cat.name}"

        id = cat.parent_id
        until id.nil? do
          tree[id][:children_paths] += ".#{cat.name}"
          id = tree[id][:parent_id]
        end
      end
      
      return tree[nil][:children]
    else
      return current_user.categories
    end
  end

  def self.get_uncategorised
    cat = Category.new
    cat.id = 0
    cat.name = 'Uncategorised'
    cat.color = '0, 0%, 50%'
    cat.symbol = 'uncategorised'
    return cat
  end

  def self.get_children(category, result = [])
    category.children.each do |c|
      c = Category.where(id: c.id).includes(:children).first
      result.push(c)
      if c.children.any?
        result = (self.get_children(c, result))
      end
    end

    return result
  end

end
