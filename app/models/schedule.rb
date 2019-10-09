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
#  next_occurrence_utc :datetime
#  type_of             :string(255)      default("schedule")
#  pause_until         :date
#  pause_until_utc     :datetime
#  current_period_id   :integer          default(0)
#  hash_id             :string(255)
#

class Schedule < ApplicationRecord
  include Friendlyable

  validates :name, :start_date, presence: true
  #validates :name, format: { without: /[-\._~:\/\?#\[\]@!\$&'\(\)\*\+,;={}"]/, message: "Special characters -._~:/?#[]@!$&\'()*+,;={}\" not allowed" }
  validates :period_num, numericality: true
  validates :period_num, numericality: { only_integer: true }
  validates :period_num, numericality: { greater_than: 0, message: "'Run every' must be greater than zero" }
  validate :plan, :on => :create
  validate :schedule_type, :on => :create

  belongs_to :user
  has_and_belongs_to_many :user_transactions, foreign_key: "schedule_id", class_name: "Transaction", dependent: :destroy

  def self.get_all_transactions_until_date(user, until_date, start_date=nil)
    return GetTransactionsUntilDate.new(user, until_date, start_date).perform
  end

  def self.get_form_params(schedule)
    return GetFormParams.new(schedule).perform
  end

  def self.create_from_form(params, current_user, testing=false, type="Schedule")
    schedule = CreateFromForm.new(params, current_user, testing, type).perform()

    if schedule.is_a?(ActiveRecord::Base)
      tz = TZInfo::Timezone.get(schedule.timezone)

      date = [schedule.start_date, tz.utc_to_local(Time.now.utc).to_date + 1].max unless schedule.start_date.nil?
      date ||= tz.utc_to_local(Time.now.utc).to_date

      next_occurrence = self.next_occurrence(schedule, date: date, return_datetime: true)
      schedule.next_occurrence = tz.utc_to_local(next_occurrence).to_date unless next_occurrence.nil?
      schedule.next_occurrence_utc = next_occurrence
    end

    return schedule
  end

  def self.pause(params, schedule, current_user)
    tz = TZInfo::Timezone.get(current_user.timezone)
    d = params[:pause_until].to_date

    schedule.pause_until = d
    schedule.pause_until_utc = tz.local_to_utc(d.to_datetime)
    schedule.save
    
    return schedule
  end

  def self.next_occurrence(schedule, date: nil, testing: false, return_datetime: false, ignore_valid: false)
    return NextOccurrence.new(schedule, date, testing, return_datetime).perform if schedule.valid? || ignore_valid
  end

  def self.previous_occurrence(schedule, date=nil)
    return PreviousOccurrence.new(schedule, date).perform
  end

  def self.run_schedules(datetime=nil, schedules=nil)
    transactions = RunSchedules.new(datetime, schedules).perform
    transactions += self.run_scheduled_transactions
    return transactions
  end

  def self.run_scheduled_transactions(transactions=nil)
    return RunScheduledTransactions.new(transactions).perform
  end

  def self.create_income(current_user, params)
    CreateFromSimpleForm.new(current_user, params, "main", "income", false).perform()
  end

  def self.create_expense(current_user, params)
    CreateFromSimpleForm.new(current_user, params, "fixed_expense").perform()
  end

  def self.edit(params, schedule)
    schedule_params = CreateFromForm.new(params, schedule.user, false, schedule.type_of, true, schedule.is_active).perform()
    return schedule_params
  end

private

  def plan
    
    if type_of != 'main'    
      plan = APP_CONFIG['plans'][user.subscription]
      plan ||= APP_CONFIG['plans']['free']

      schedules = user.schedules.where("type_of != 'main' AND id IS NOT NULL")

      if schedules.length >= plan['max_schedules']
        errors.add(:Plan, I18n.t('schedule.failure.upgrade_for_schedules')) unless plan['max_schedules'] < 0
      end
    end

  end

  def schedule_type
    if type_of == 'main'
      main_schedule = user.schedules.where(type_of: 'main').take

      unless main_schedule.nil?
        errors.add(:schedule, "<a href='/plans'>" + I18n.t('schedule.failure.multiple_main_schedules') + "</a>")
      end
    end
  end

end
