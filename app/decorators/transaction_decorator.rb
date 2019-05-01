class TransactionDecorator < ApplicationDecorator
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

  def transfer_message
    unless model.transfer_account_id.nil?
      message = "Transferred "
      if model.direction == -1
        message += "to "
      else
        message += "from "
      end
      message += Account.find(model.transfer_account_id).name
      return message
    end
    return ""
  end

  def conversion_message
    if model.amount != model.account_currency_amount
      return "~" + Money.new(model.amount, model.currency).format
    else
      return ""
    end
  end

  def time_num

    return model.local_datetime.strftime("%H%M%S").to_i
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
