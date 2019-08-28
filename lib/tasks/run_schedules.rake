task :run_schedules => :environment do
	puts "Running schedules"
	Schedule.run_schedules
	puts "Finished running schedules"
end