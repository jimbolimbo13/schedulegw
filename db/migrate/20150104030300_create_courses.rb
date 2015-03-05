class CreateCourses < ActiveRecord::Migration
  def change
  	create_table :courses do |t|
  		t.string :crn
    	t.string :gwid
    	t.string :section
    	t.string :course_name
    	t.string :hours
    	t.string :days
    	t.string :day1_start
    	t.string :day1_end
    	t.string :day2_start
    	t.string :day2_end
    	t.string :day3_start
    	t.string :day3_end
    	t.string :day4_start
    	t.string :day4_end
    	t.string :day5_start
    	t.string :day5_end
    	t.string :day6_start
    	t.string :day6_end
    	t.string :day7_start
    	t.string :day7_end
    	t.boolean :llm_only
    	t.boolean :jd_only
    	t.string :course_name_2
    	t.boolean :alt_schedule
    	t.text :additional_info
    	t.boolean :manual_lock
        t.string :professor
        t.integer :prof_id
        t.string :final_time
        t.string :final_date
        t.string :school
        t.integer :schedule_id
      	t.timestamps
    end
    add_index(:courses, :crn, unique: true)
  end
end
