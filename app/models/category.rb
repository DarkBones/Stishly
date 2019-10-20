# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  color      :string(255)
#  symbol     :string(255)
#  user_id    :bigint
#  parent_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hash_id    :string(255)
#  position   :integer
#

class Category < ApplicationRecord
  include Friendlyable
  
  belongs_to :user
  has_many :transactions
  has_one :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  
  def self.create(current_user, params)
    category = current_user.categories.new(params)

    if current_user.categories.length == 0
      position = 0
    else
      position = current_user.categories.order(:position).first.position - 1 unless current_user.categories.order(:position).first.nil?
    end

    position ||= 0
    category.position = position

    unless category.color.nil?
      category.color = nil if category.color.length < 4
    end

    category.save
    return category
  end

  def self.update(category, params)
    params[:color] = nil if params[:color].length < 4
    return category.update!(params)
  end

  def self.delete(category)
    unless self.where(id: category.parent_id).empty?
      parent_category = self.where(id: category.parent_id).take.id
    else
      parent_category = nil
    end

    category.children.each do |c|
      c.parent_id = parent_category
      c.save
    end

    category.destroy
  end

  def self.get_user_categories(current_user, as_array=false, include_blank=false, include_uncategorised = true, blank_string = "- any -")
    if as_array
      tree = Hash.new { |h,k| h[k] = { :name => nil, :children => [ ], :children_paths => "", :parent_id => nil } }

      idx = 0

      if include_blank
        tree[idx][:id] = ""
        tree[idx][:name] = blank_string
        tree[idx][:color] = ""
        tree[idx][:symbol] = "any"
        tree[idx][:parent_id] = nil
        tree[idx][:children_paths] = ""

        tree[nil][:children].push(tree[idx])

        idx += 1
      end

      if include_uncategorised
        tree[idx][:id] = 0
        tree[idx][:name] = "Uncategorised"
        tree[idx][:color] = "#808080"
        tree[idx][:symbol] = nil
        tree[idx][:parent_id] = nil
        tree[idx][:children_paths] = "uncategorised"
        tree[idx][:color_inherited] = false

        tree[nil][:children].push(tree[idx])
      end

      # set the parent_keys first (required for recursive search)
      current_user.categories.order(:name).each do |cat|
        tree[cat.id][:parent_id] = cat.parent_id
      end

      current_user.categories.decorate.order(:position).each do |cat|
        tree[cat.id][:id] = cat.hash_id
        tree[cat.id][:name] = cat.name
        tree[cat.id][:color] = cat.color
        tree[cat.id][:symbol] = cat.symbol
        tree[cat.id][:children_paths] += ".#{cat.name}"
        tree[cat.id][:color_inherited] = cat.color_inherited?
        
        tree[cat.parent_id][:children].push(tree[cat.id])

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
    cat.color = '#808080'
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

  def self.get_amount(category, start_date: nil)    
    transactions = self.get_transactions(category, start_date: start_date)
    return transactions.sum(:user_currency_amount)
  end

  def self.get_historic_data(category, start_date: nil)
    tz = TZInfo::Timezone.get(category.user.timezone)
    currency = Money::Currency.new(category.user.currency)

    transactions = self.get_transactions(category, start_date: start_date)
    start_date ||= transactions.first.local_datetime

    data = {}
    current_date = start_date
    stopper = 100
    while current_date < tz.utc_to_local(Time.now.utc)
      data[current_date.strftime("%d-%b-%Y")] = (transactions.where("date(local_datetime) <= ?", current_date).sum(:user_currency_amount) * -1).to_f / currency.subunit_to_unit
      current_date += 1.day
      stopper -= 1
      break if stopper < 0
    end

    return data
  end

  def self.get_transactions(category, start_date: nil)
    ids = self.get_ids(category)

    if start_date.nil?
      return category.user.transactions.where("
        is_scheduled = false
        AND local_datetime IS NOT NULL
        AND is_main = true
        AND is_cancelled = false
        AND is_queued = false
        AND scheduled_date IS NULL
        AND category_id in (?)
        ", ids).order(:local_datetime)
    else
      return category.user.transactions.where("
        is_scheduled = false
        AND local_datetime IS NOT NULL
        AND is_main = true
        AND is_cancelled = false
        AND is_queued = false
        AND scheduled_date IS NULL
        AND category_id in (?)
        AND local_datetime >= ?
        ", ids, start_date).order(:local_datetime)
    end

  end

private
    
  # returns a collection of ids of the given category and its children
  def self.get_ids(category, ids=[])
    ids.push(category.id)

    category.children.each do |child|
      ids += self.get_ids(child)
    end

    return ids
  end

end
