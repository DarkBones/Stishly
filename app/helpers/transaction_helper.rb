module TransactionHelper
  def get_transaction_time(t)
    tz = TZInfo::Timezone.get(t.timezone)
    return tz.utc_to_local(t.created_at)
  end

  def distinct_dates(transactions, dates=[])
    transactions.each do |t|
      next if t.is_scheduled
      unless (dates.include? t.local_datetime.to_date)
        dates.push(t.local_datetime.to_date)
      end
    end
    return dates
  end

  def transaction_form_params(transaction)
    params = {}

    params[:transactions_total] = 0
    params[:transfer_conversion_class] = "default-hide"
    params[:transfer_conversion_style] = "display: none;"

    type = ""
    if transaction.transfer_transaction_id
      type = "transfer"
    elsif transaction.amount > 0
      type = "income"
    else
      type = "expense"
    end
    params[:type] = type

    if type == "transfer"
      params[:type_bg_color] = "bg-warning"
      params[:type_transfer_class] = "active"
      params[:single_account_style] = "display: none;"
      params[:currency_style] = "display: none;"
      params[:category_class] = "default-hide"
      params[:category_style] = "display: none;"

      from_account_currency = transaction.account.currency
      to_account_currency = transaction.transfer_transaction.account.currency unless transaction.transfer_transaction.nil?
      to_account_currency ||= transaction.account.currency

      if from_account_currency != to_account_currency
        params[:transfer_conversion_class] = "default-show"
        params[:transfer_conversion_style] = ""
      else
        params[:transfer_conversion_class] = "default-hide hidden"
      end

    elsif type == "income"
      params[:type_bg_color] = "bg-success"
      params[:type_income_class] = "active"
      params[:transfer_account_style] = "display: none;"
    else
      params[:type_bg_color] = "bg-danger"
      params[:type_expense_class] = "active"
      params[:transfer_account_style] = "display: none;"
    end

    account = Account.get_accounts(current_user)[0]
    currency = account.currency
    if transaction.persisted?
      account = current_user.accounts.find(transaction.account_id)
      currency = transaction.currency

      params[:from_account_name] = transaction.account.slug
      params[:to_account_name] = params[:from_account_name]

      if transaction.transfer_account_id
        params[:to_account_name] = current_user.accounts.find(transaction.transfer_account_id).name
      end

      if currency == account.currency || currency.nil?
        params[:currency_conversion_style] = "display: none;"
        params[:currency_conversion_class] = "default-hide"
      else
        params[:conversion_rate] = transaction.account_currency_amount.to_f / transaction.amount.to_f
        params[:currency_conversion_class] = "default-show"
      end

    else
      params[:currency_conversion_style] = "display: none;"
      params[:currency_conversion_class] = "default-hide"
      params[:from_account_name] = account.slug
      params[:to_account_name] = params[:from_account_name]
    end

    if transaction.children.length > 0
      params[:multiple_transaction_class] = "active"
      params[:single_transaction_selected] = false
      params[:multiple_transaction_selected] = true
      params[:amount_style] = "display: none;"
      params[:amount_class] = "default-hide"
      params[:transactions_class] = "default-show"
      params[:transactions_total] = Money.new(transaction.amount.abs, transaction.currency).format
    else
      params[:single_transaction_class] = "active"
      params[:single_transaction_selected] = true
      params[:multiple_transaction_selected] = false
      params[:transactions_style] = "display: none;"
      params[:amount_class] = "default-show"
      params[:transactions_class] = "default-hide"
    end

    params[:schedule_type] = 0
    if transaction.queue_scheduled
      params[:schedule_type] = 1
    end

    unless transaction.local_datetime.nil?
      dateclass = "datepicker-null"
      date = transaction.local_datetime.strftime("%d-%b-%Y")
    else
      dateclass = ""
      date = nil
    end

    params[:dateclass] = dateclass
    params[:date] = date

    params[:category_hash_id] = "0"
    if transaction.category_id > 0
      params[:category_hash_id] = transaction.category.hash_id
    end

    return params
  end

end
