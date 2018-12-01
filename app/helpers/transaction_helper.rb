module TransactionHelper
  def get_transaction_time(t)
    tz = TZInfo::Timezone.get(t.timezone)
    return tz.utc_to_local(t.created_at)
  end

  def distinct_dates(transactions)
    dates = []
    transactions.each do |t|
      if !(dates.include? t.created_at.to_date)
        dates.push(t.created_at.to_date)
      end
    end
    return dates
  end
end
