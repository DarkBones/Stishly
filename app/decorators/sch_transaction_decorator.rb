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

  def amount_single
    currency = Money::Currency.new(model.currency)
    return (model.amount / currency.subunit_to_unit).abs
  end

  def amount_multiple
    currency = Money::Currency.new(model.currency)
    if model.children.length > 0
      result = ""
      model.children.each do |ct|
        result += "#{ct.description} #{(ct.amount / currency.subunit_to_unit).abs}\n"
      end
      return result
    else
      return ""
    end
  end

end
