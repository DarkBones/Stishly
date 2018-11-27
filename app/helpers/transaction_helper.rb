module TransactionHelper
  def get_transaction_time(t)
    tz = TZInfo::Timezone.get(t.timezone)
    return tz.utc_to_local(t.created_at)
  end
end
