# == Schema Information
#
# Table name: schedule_occurrences
#
#  id               :bigint           not null, primary key
#  schedule_id      :bigint
#  occurrence_utc   :datetime
#  occurrence_local :datetime
#

class ScheduleOccurrence < ApplicationRecord
end
