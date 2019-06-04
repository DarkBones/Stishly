# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint(8)        not null, primary key
#  name                :string(255)
#  user_id             :bigint(8)
#  start_date          :date
#  end_date            :date
#  period              :string(255)
#  period_num          :integer          default(0)
#  days                :integer          default(0)
#  days_month          :string(255)
#  days_month_day      :integer
#  days_exclude        :integer
#  exclusion_met       :string(255)
#  exclusion_met_day   :integer
#  timezone            :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  is_active           :boolean          default(TRUE)
#  next_occurrence     :date
#  last_occurrence     :date
#  next_occurrence_utc :datetime
#

class Schedule < ApplicationRecord

  validates :name, :start_date, presence: true
  validates :name, format: { without: /[-\._~:\/\?#\[\]@!\$&'\(\)\*\+,;={}"]/, message: "Special characters -._~:/?#[]@!$&\'()*+,;={}\" not allowed" }
  validates :period_num, numericality: true
  validates :period_num, numericality: { only_integer: true }
  validates :period_num, numericality: { greater_than: 0, message: "'Run every' must be greater than zero" }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false, message: I18n.t('schedule.failure.already_exists') }

  #validates_numericality_of :period_num, :greater_than => 0

  belongs_to :user
  has_and_belongs_to_many :user_transactions, foreign_key: "schedule_id", class_name: "Transaction"

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

  def self.next_occurrence(schedule, date=nil, testing=false, return_datetime=false, ignore_valid=false)
    return NextOccurrence.new(schedule, date, testing, return_datetime).perform if schedule.valid? || ignore_valid
  end

  def self.previous_occurrence(schedule, date=nil)
    return PreviousOccurrence.new(schedule, date).perform
  end

end











