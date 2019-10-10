class AppController < ApplicationController
  def index
    @account_id = ''

    @upcoming_transactions = Schedule.get_all_transactions_until_date(current_user, 14.days.from_now)
    @history_data = ChartDatum.user_history(current_user)
  end
end
