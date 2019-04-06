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

class Schedule < ApplicationRecord
  validates :user_id, :timezone, presence: true
  validates_numericality_of :period_num, :greater_than => 0

  belongs_to :user
  has_many :schedule_joins
  has_many :transactions, through: :schedule_joins

  def self.create_from_form(params, current_user, testing=false)
    schedule = CreateFromForm.new(params, current_user, testing).perform()

    if schedule.is_a?(ActiveRecord::Base)
      tz = TZInfo::Timezone.get(schedule.timezone)

      next_occurrence = self.next_occurrence(schedule, nil, false, true)
      schedule.next_occurrence = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?
      schedule.next_occurrence_utc = next_occurrence
    end

    return schedule
  end

  def self.next_occurrence(schedule, date=nil, testing=false, return_datetime=false)
    return NextOccurrence.new(schedule, date, testing, return_datetime).perform
  end

end











