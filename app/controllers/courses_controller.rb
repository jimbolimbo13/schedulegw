class CoursesController < ApplicationController
	before_action :require_admin

	#GET /courses/1/edit
	def edit
		@course = Course.find(params[:id])
		@pinned_books = []
		@course.pinned_isbn.each do |isbn|
			@pinned_books << Listbook.find_by(:isbn => isbn.to_s) unless Listbook.find_by(:isbn => isbn.to_s) == nil
		end
		@pinned_books.uniq!
	end

	#GET /courses
	def index
		@courses = Course.all.order(:gwid)
		@stats = [];
		@stats.push( {name: 'Users', value: User.count.to_i} );
		@stats.push( {name: 'Schedules Saved in Database', value: Schedule.count.to_i} )
		@stats.push( {name: 'Schedules Emailed', value: School.find(current_user.school.id).emails_sent.to_i} )
		@stats.push( {name: 'Schedules Created', value: School.find(current_user.school.id).schedules_created.to_i} )

		@new_users = User.select(:id, :name, :email).order(created_at: :desc).first(20)

		# Suggestions submitted for missing books.
		@booklistsuggestions = Booklistsuggestion.all.order(created_at: :desc).first(50)

		# Most popular Courses by how many schedules they appear in.
		@most_popular = Course.popular_courses

		# Feedback Submissions
		@unresolved_feedback = Feedback.all.where(resolved: false)

	end

	def gwufinals
		@final_dates = School.find_by(:name => "GWU").final_date_options
		@final_times = School.find_by(:name => "GWU").final_time_options

		@final_dates.each_with_index do |date, dateindex|
			@final_times.each_with_index do |time, timeindex|
				@square = Course.where(:final_date => date, :final_time => time)
				instance_variable_set("@grid#{dateindex}#{timeindex}", @square)
			end
		end

		@orphans = Course.all.where(:final_time => nil).select { |course| course.final_date }

	end


	def show
		@course = Course.find(params[:id])
	end

	def new
		@course = Course.new
	end

	def update
		@course = Course.find(params[:id])

		if params[:add_pinned_isbn]
			isbn = params[:add_pinned_isbn].to_s.gsub(/\D/, '')
			@course.pinned_isbn << isbn unless isbn == ""
			@course.pinned_isbn.uniq!
			if @course.save!
				# AJAX verification of successful save goes here. probably .js something or other ?
			end
		end

		respond_to do |format|
	      if @course.update(course_params)
					flash[:notice] = "Saved Changes!"
					format.html { redirect_to "/courses/#{ @course.next.id }/edit" } if params[:next_record]
					format.html { redirect_to "/courses/#{ @course.previous.id }/edit" } if params[:previous_record]
					format.html { redirect_to edit_course_path }
					format.json { render :index, status: :ok, location: @course }
	      else
					flash[:danger] = "Didn't save!"
	        format.html { render :index }
	        format.json { render json: @course.errors, status: :unprocessable_entity }
	      end
	    end
	end

	private
		def require_admin
			redirect_to root_path unless current_user && current_user.admin == true
		end

		def course_params
			params.require(:course).permit(	:crn,
											:gwid,
											:section,
											:course_name,
											:professor,
											:hours,
											:days,
											:llm_only,
											:jd_only,
											:course_name_2,
											:alt_schedule,
											:additional_info,
											:final_date,
											:final_time,
											:manual_lock,
											:isbn,
											:pinned_isbn,
											:wrong_isbn
											)
		end

end
