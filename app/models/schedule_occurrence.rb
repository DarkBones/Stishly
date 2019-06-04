# == Schema Information
#
# Table name: schedule_occurrences
#
#  id               :bigint(8)        not null, primary key
#  schedule_id      :bigint(8)
#  occurrence_utc   :datetime
#  occurrence_local :datetime
#

class ScheduleOccurrence < ApplicationRecord
end
