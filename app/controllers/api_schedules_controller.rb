class ApiSchedulesController < BaseApiController

	def index
		render json: prepare_json(JSON.parse(@user.schedules.to_json))
	end

	def show
		schedule = @user.schedules.find(params[:schedule])
		render json: "not found", status: :not_found and return if schedule.nil?

		render json: prepare_json(JSON.parse(schedule.to_json))
	end

	def transactions
		schedule = @user.schedules.find(params[:schedule])
		render json: "not found", status: :not_found and return if schedule.nil?

		render json: prepare_json(JSON.parse(schedule.user_transactions.to_json))
	end

	def next_occurrence
		schedule = @user.schedules.find(params[:schedule])
		render json: "not found", status: :not_found and return if schedule.nil?

		next_occurrence = schedule.next_occurrence.to_date
		if params[:user_format]
			if params[:include_weekday]
				next_occurrence = User.format_date(next_occurrence, true)
			else
				next_occurrence = User.format_date(next_occurrence)
			end

		end

		render json: next_occurrence
	end

	def next_occurrences
		schedule = @user.schedules.find(params[:schedule])
		render json: "not found", status: :not_found and return if schedule.nil?

		count = params[:count].to_i
		if count > 50
			count = 50
		elsif count < 1
			count = 1
		end
		count -= 1

		next_occurrences = []
		next_occurrence = schedule.next_occurrence.to_date
		next_occurrences.push(next_occurrence)

		count.times do
			next_occurrence = Schedule.next_occurrence(schedule, next_occurrence + 1)
			next_occurrences.push(next_occurrence)
		end

		render json: next_occurrences

	end

	def next_occurrences_from_form
		params[:name] = "next occurrence"
		schedule = Schedule.create_from_form(schedule_params, @user)

		render json: "bad request", status: :bad_request and return unless schedule.is_a?(ActiveRecord::Base)
		
		count = params[:count].to_i
		if count > 50
			count = 50
		elsif count < 1
			count = 1
		end

		occurrences = []
		next_occurrence = params[:start_date].to_date
		count.times do
			next_occurrence = Schedule.next_occurrence(schedule, next_occurrence, false, false, true)

			break if next_occurrence.nil?

			occurrences.push(User.format_date(next_occurrence, true))
			next_occurrence += 1
		end

		render json: occurrences
	end

	def get_next_schedule_occurrences
    schedule = Schedule.create_from_form(schedule_params, current_user)
    
    occurrences = []
    if schedule.is_a?(ActiveRecord::Base)
      next_occurrence = params[:start_date].to_date
      params[:occurrence_count].to_i.times do
        next_occurrence = Schedule.next_occurrence(schedule, next_occurrence, false, false, true)

        unless next_occurrence.nil?
          occurrences.push(("<li>"+User.format_date(next_occurrence, true)+"</li>").html_safe)

          next_occurrence += 1
        else
          break
        end
      end
    else
      occurrences.push(("<p id='next_occurrence_error'>ERROR: #{schedule}</p>").html_safe)
    end

    render json: occurrences
  end

private

	def schedule_params
    params.permit(
      :name,
      :type,
      :start_date,
      :timezone,
      :schedule,
      :run_every,
      :days,
      :days2,
      :dates_picked,
      :weekday_mon,
      :weekday_tue,
      :weekday_wed,
      :weekday_thu,
      :weekday_fri,
      :weekday_sat,
      :weekday_sun,
      :end_date,
      :weekday_exclude_mon,
      :weekday_exclude_tue,
      :weekday_exclude_wed,
      :weekday_exclude_thu,
      :weekday_exclude_fri,
      :weekday_exclude_sat,
      :weekday_exclude_sun,
      :dates_picked_exclude,
      :exclusion_met1,
      :exclusion_met2,
      :occurrence_count
      )
  end

end
