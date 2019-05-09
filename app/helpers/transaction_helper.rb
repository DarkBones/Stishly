module TransactionHelper
  def get_transaction_time(t)
    tz = TZInfo::Timezone.get(t.timezone)
    return tz.utc_to_local(t.created_at)
  end

  def distinct_dates(transactions, dates=[])
    transactions.each do |t|
      unless (dates.include? t.local_datetime.to_date)
        dates.push(t.local_datetime.to_date)
      end
    end
    return dates
  end

  def transaction_form_params(transaction)
    params = {}

    type = ""
    if transaction.transfer_transaction_id
      type = "transfer"
    elsif transaction.amount > 0
      type = "income"
    else
      type = "expense"
    end
    params[:type] = type

    params[:single_account_style] = "display: block;"
    params[:transfer_account_style] = "display: none;"
    if type == "transfer"
      params[:type_bg_color] = "bg-warning"
      params[:type_transfer_class] = "active"
      params[:single_account_style] = "display: none;"
      params[:transfer_account_style] = "display: block;"
      params[:currency_style] = "display: block;"
    elsif type == "income"
      params[:type_bg_color] = "bg-success"
      params[:type_income_class] = "active"
    else
      params[:type_bg_color] = "bg-danger"
      params[:type_expense_class] = "active"
    end

    account = Account.get_accounts(current_user)[0]
    currency = account.currency
    if transaction.persisted?
      account = current_user.accounts.find(transaction.account_id)
      currency = transaction.currency

      params[:from_account_name] = transaction.account.name
      params[:to_account_name] = params[:from_account_name]

      if transaction.transfer_account_id
        params[:to_account_name] = current_user.accounts.find(transaction.transfer_account_id).name
      end

      if currency == account.currency
        params[:currency_conversion_style] = "display: none;"
      else
        params[:conversion_rate] = transaction.account_currency_amount.to_f / transaction.amount.to_f
      end

    else
      params[:from_account_name] = account.name
      params[:to_account_name] = params[:from_account_name]
    end

    if transaction.children.length > 0
      params[:multiple_transaction_class] = "active"
      params[:single_transaction_selected] = false
      params[:multiple_transaction_selected] = true
      params[:amount_style] = "display: none;"
    else
      params[:single_transaction_class] = "active"
      params[:single_transaction_selected] = true
      params[:multiple_transaction_selected] = false
      params[:transactions_style] = "display: none;"
    end

    return params
  end

end
