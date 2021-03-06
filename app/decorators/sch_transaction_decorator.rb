class SchTransactionDecorator < ApplicationDecorator
  delegate_all

  def category
    if model.category
      return model.category
    elsif model.transfer_transaction_id
      category = Category.new

      if model.direction == -1
        category.symbol = "sign-out-alt"
      else
        category.symbol = "sign-in-alt"
      end

      category.name = "transfer"
      category.color = "#FFC107";
      return category
    else
      category = Category.new
      category.symbol = "uncategorised"
      category.name = "uncategorised"
      category.color = "#808080";
      return category
    end
  end

  def amount_single
    currency = Money::Currency.new(model.currency)

    amount = format_amount(model.amount.abs, currency)

    return amount
  end

  def amount_multiple
    currency = Money::Currency.new(model.currency)

    if model.children.length > 0
      result = ""

      model.children.each do |ct|
        amount = ct.amount * model.direction
        result += "#{ct.description} #{format_amount(amount, currency)}\n"
      end

      return result
    else
      return ""
    end
  end
  
private

    def format_amount(amount, currency)
      amount = (amount.to_f / currency.subunit_to_unit)

      if currency.subunit_to_unit > 1
        amount = amount.to_s
        cents_str = amount.split(".")[1]
        cents_digits = Math.log10(currency.subunit_to_unit).ceil
        while cents_str.length < cents_digits
          amount += "0"
          cents_str = amount.split(".")[1]
        end
      else
        amount = amount.to_i.to_s
      end

      return amount
    end

end
