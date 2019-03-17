# == Schema Information
#
# Table name: schedules
#
#  id                :bigint(8)        not null, primary key
#  name              :string(255)
#  user_id           :bigint(8)
#  start_date        :date
#  end_date          :date
#  period            :string(255)
#  period_num        :integer
#  days              :integer
#  days_month        :string(255)
#  days_month_day    :string(255)
#  days_exclude      :integer
#  exclusion_met     :string(255)
#  exclusion_met_day :string(255)
#  timezone          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_active         :boolean          default(TRUE)
#

# == Schema Information
#
# Table name: schedules
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)
#  transaction_id    :bigint(8)
#  account_id        :bigint(8)
#  start_date        :date
#  end_date          :date
#  period            :string(255)
#  period_day        :integer
#  period_occurences :integer
#  exception_days    :string(255)
#  exception_rule    :string(255)
#  next_occurrence   :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Schedule < ApplicationRecord
  validates :name, :start_date, :user_id, presence: true

  belongs_to :user
  has_many :schedule_joins
  has_many :transactions, through: :schedule_joins

  def self.create_from_form(params, current_user)
    schedule = CreateFromForm.new(params, current_user).perform()
    return schedule
  end

  def self.next_occurrence(schedule, date=nil)
    # set the start date
    if date == nil
      tz = TZInfo::Timezone.get(schedule.timezone)
      date = tz.utc_to_local(Time.now.to_date)
    end

    # find the next year
    

    # find the next month


    # find the next day
    

  end

end











