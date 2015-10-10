class AddSemester < ActiveRecord::Migration
  def up
    create_table :semesters do |t|
      t.string :name
    end

    @sem = Semester.new
    @sem.name = "fall2015"
    @sem.save!

    @sem2 = Semester.new
    @sem2.name = "spring2016"
    @sem2.save!

    add_column :courses, :semester_id, :integer

    @sem_id = Semester.find_by(name: 'fall2015').id
    Course.find_each do |course|
      course.semester_id = @sem_id
      course.save!
    end

    # Add semester_id to denote which semester is currently being scraped.
    add_column :schools, :semester_id, :integer

    # Set the currently being scraped semester to spring2016 for all schools.
    School.find_each do |school|
      school.semester_id = @sem2.id
    end
    

  end
  def down
    drop_table :semesters
    remove_column :courses, :semester_id
    remove_column :schools, :semester_id
  end
end
