require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

	test "Create schedule today" do
		current_user = users(:bas)

		tz = TZInfo::Timezone.get('Australia/Sydney')

		params = {
	      type: 'simple',
	      name: 'today is great',
	      start_date: tz.utc_to_local(Time.now.utc),
	      timezone: 'Australia/Sydney',
	      schedule: 'daily',
	      run_every: '1',
	      days: 'specific',
	      days2: 'day',
	      dates_picked: '',
	      weekday_mon: '0',
	      weekday_tue: '0',
	      weekday_wed: '0',
	      weekday_thu: '0',
	      weekday_fri: '0',
	      weekday_sat: '0',
	      weekday_sun: '0',
	      end_date: '',
	      weekday_exclude_mon: '0',
	      weekday_exclude_tue: '0',
	      weekday_exclude_wed: '0',
	      weekday_exclude_thu: '0',
	      weekday_exclude_fri: '0',
	      weekday_exclude_sat: '0',
	      weekday_exclude_sun: '0',
	      dates_picked_exclude: '',
	      exclusion_met1: 'previous',
	      exclusion_met2: 'fri'
	    }

	    schedule = Schedule.create_from_form(params, current_user)
	    schedule.save

	    assert schedule.next_occurrence_utc > Time.now.utc, format_error("New schedules should not run on the date they are created")
	end

end