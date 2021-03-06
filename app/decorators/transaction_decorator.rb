class TransactionDecorator < ApplicationDecorator
  delegate_all

  def category
    if model.category
      model.category
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

  def amount
    return model.amount unless model.amount.nil?
    return 0
  end

  def category_id
    return model.category_id unless model.category_id.nil?
    return 0
  end

  def amount_formatted
    if model.children.any?
      return amount_multiple
    else
      return amount_single
    end
  end

  def amount_single
    return 0 if model.currency.nil?

    currency = Money::Currency.new(model.currency)

    return format_amount(model.amount.abs, currency)
  end

  def amount_neg
    return 0 if model.currency.nil?

    currency = Money::Currency.new(model.currency)

    return format_amount(model.amount, currency)
  end

  def amount_account
    return "" if model.account.nil?

    currency = Money::Currency.new(model.account.currency)

    return format_amount(model.account_currency_amount.abs, currency)
  end

  def amount_multiple
    return "" if model.currency.nil?

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

  def transfer_message_OLD
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

  def transfer_message
    unless model.transfer_account_id.nil?
      account_name = Account.find(model.transfer_account_id).name
      if model.direction == -1
        message = I18n.t('decorators.transaction.transfer_messages.to').sub("?to?", account_name)
      else
        message = I18n.t('decorators.transaction.transfer_messages.from').sub("?from?", account_name)
      end

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
    return model.local_datetime.strftime("%H%M%S").to_i unless model.local_datetime.nil?
    return 0
  end

  def transfer_currency_amount
    return if model.transfer_transaction.nil?

    currency = Money::Currency.new(model.currency)

    return format_amount(model.transfer_transaction.account_currency_amount.abs, currency)
  end

  def transfer_currency
    return if model.transfer_transaction.nil?
    return model.transfer_transaction.account.currency
  end

  def transfer_rate
    return 1 if model.transfer_transaction.nil?
    return 1 if model.transfer_transaction.account.currency == model.account.currency
    return 1 if model.transfer_transaction.account_currency_amount == 0
    return 1 if model.account_currency_amount.nil?
    return 1 if model.transfer_transaction.account_currency_amount.nil?

    return format_amount(model.account_currency_amount.abs, model.account.currency).to_f / format_amount(model.transfer_transaction.account_currency_amount.abs, model.account.currency).to_f
  end

private

  def format_amount(amount, currency)
    currency = Money::Currency.new(currency) if currency.class == String

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
