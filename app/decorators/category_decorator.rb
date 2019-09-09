class CategoryDecorator < ApplicationDecorator
  delegate_all

  def color
    return model.color unless model.color.nil?
    return "0, 0%, 50%" if model.parent_id.nil?
    return "0, 0%, 50%" if Category.find(model.parent_id).nil?
    return "0, 0%, 50%" if Category.find(model.parent_id).color.nil?

    return Category.find(model.parent_id).color
  end

end
