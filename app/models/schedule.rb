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
  validates :name, :start_date, :user_id, presence: true
  validates_numericality_of :period_num, :greater_than => 0

  belongs_to :user
  has_many :schedule_joins
  has_many :transactions, through: :schedule_joins

  def self.create_from_form(params, current_user)
    schedule = CreateFromForm.new(params, current_user).perform()
    return schedule
  end

  def self.next_occurrence(schedule, date=nil)
    return NextOccurrence.new(schedule, date).perform
  end

end











