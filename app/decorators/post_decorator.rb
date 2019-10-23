class PostDecorator < ApplicationDecorator
  delegate_all

  def body_html
  	return Post.format_html(model)
  end

end
