# == Schema Information
#
# Table name: schedule_occurrences
#
#  id                        :bigint(8)        not null, primary key
#  schedule_id               :bigint(8)
#  occurrence_local_datetime :date
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ScheduleOccurrence < ApplicationRecord
end
