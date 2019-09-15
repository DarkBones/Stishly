class CategoryDecorator < ApplicationDecorator
  delegate_all

  def color
  	return model.color unless model.color.nil?

  	unless model.parent_id.nil?
  		parent_id = model.parent_id
  		until parent_id.nil?
  			parent = Category.find(parent_id)

  			unless parent.color.nil?
  				return parent.color
  			end

  			parent_id = parent.parent_id
  		end
  	end

  	return "#808080"
  end

  def color_inherited?
    return model.color.nil? || model.color.length < 4
  end

  def color_direct
    return model.color
  end

end
