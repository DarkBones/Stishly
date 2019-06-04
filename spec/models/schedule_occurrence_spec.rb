# == Schema Information
#
# Table name: schedule_occurrences
#
#  id               :bigint(8)        not null, primary key
#  schedule_id      :bigint(8)
#  occurrence_utc   :datetime
#  occurrence_local :datetime
#

require 'rails_helper'

RSpec.describe ScheduleOccurrence, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
