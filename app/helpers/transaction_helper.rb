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
end
