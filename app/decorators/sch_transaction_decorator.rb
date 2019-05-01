class SchTransactionDecorator < ApplicationDecorator
  delegate_all

  def category
    if model.category
      model.category
    elsif model.transfer_transaction_id
      category = Category.new
      category.symbol = "transfer"
      category.name = "transfer"
      category.color = "45, 100%, 51%";
      return category
    else
      category = Category.new
      category.symbol = "uncategorised"
      category.name = "uncategorised"
      category.color = "0, 0%, 50%";
      return category
    end
  end

end
