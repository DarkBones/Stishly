# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint           not null, primary key
#  name                :string(255)
#  user_id             :bigint
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
#  type_of             :string(255)      default("schedule")
#  pause_until         :date
#  pause_until_utc     :datetime
#

class Schedule < ApplicationRecord

  validates :name, :start_date, presence: true
  validates :name, format: { without: /[-\._~:\/\?#\[\]@!\$&'\(\)\*\+,;={}"]/, message: "Special characters -._~:/?#[]@!$&\'()*+,;={}\" not allowed" }
  validates :period_num, numericality: true
  validates :period_num, numericality: { only_integer: true }
  validates :period_num, numericality: { greater_than: 0, message: "'Run every' must be greater than zero" }
  #validate :subscription

  belongs_to :user
  has_and_belongs_to_many :user_transactions, foreign_key: "schedule_id", class_name: "Transaction"

  def self.get_all_transactions_until_date(user, until_date, current_date=nil)
    
  end

  def self.create_from_form(params, current_user, testing=false, type="Schedule")
    schedule = CreateFromForm.new(params, current_user, testing, type).perform()

    if schedule.is_a?(ActiveRecord::Base)
      tz = TZInfo::Timezone.get(schedule.timezone)

      next_occurrence = self.next_occurrence(schedule, nil, false, true)
      schedule.next_occurrence = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?
      schedule.next_occurrence_utc = next_occurrence
    end

    return schedule
  end

  def self.pause(params, current_user)
    schedule = current_user.schedules.find_by_id(params[:id])
    return if schedule.nil?
    
    tz = TZInfo::Timezone.get(current_user.timezone)
    d = params[:pause_until].to_date
    schedule.pause_until = d
    schedule.pause_until_utc = tz.local_to_utc(d.to_datetime)
    schedule.save

  end

  def self.next_occurrence(schedule, date=nil, testing=false, return_datetime=false, ignore_valid=false)
    return NextOccurrence.new(schedule, date, testing, return_datetime).perform if schedule.valid? || ignore_valid
  end

  def self.previous_occurrence(schedule, date=nil)
    return PreviousOccurrence.new(schedule, date).perform
  end

  def self.run_schedules(datetime=nil, schedules=nil)
    return RunSchedules.new(datetime, schedules).perform
  end

  def self.create_income(current_user, params)
    CreateFromSimpleForm.new(current_user, params, "main", "income", false).perform()
  end

  def self.create_expense(current_user, params)
    CreateFromSimpleForm.new(current_user, params, "fixed_expense").perform()
  end

private
  
  def subscription
    subscription_tier = user.subscription_tier if user.subscription_tier_id > 0
    subscription_tier ||= SubscriptionTier.where(name: "Free").take()
    return unless subscription_tier

    max = 0
    schedules = user.schedules.where(type_of: type_of)

    if type_of.downcase == "schedule"
      max = subscription_tier.max_schedules
      message = "Upgrade to premium for more schedules"
    elsif type_of.downcase == "fixed_expense"
      max = subscription_tier.max_fixed_expenses
      message = "Upgrade to premium for more fixed expenses"
    end
    
    if schedules.length >= max
      errors.add(:schedule, message)
    end

  end

end
