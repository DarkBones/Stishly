class TransactionDecorator < ApplicationDecorator
  delegate_all

  def category
    if model.category
      model.category
    else
      category = Category.new
      category.symbol = "uncategorised"
      category.name = "uncategorised"
      return category
    end
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
