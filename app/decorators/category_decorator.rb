class CategoryDecorator < ApplicationDecorator
  delegate_all

  def color
  	return model.color unless model.color.nil?

  	unless model.parent_id.nil?
  		parent_id = model.parent_id
  		while !parent_id.nil?
  			parent = Category.find(parent_id)

  			unless parent.color.nil?
  				return parent.color
  				break
  			end

  			parent_id = parent.parent_id
  		end
  	end

  	return "0, 0%, 50%"
  end

end
