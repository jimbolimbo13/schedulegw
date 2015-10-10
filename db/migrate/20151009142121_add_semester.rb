class AddSemester < ActiveRecord::Migration
  def up
    create_table :semesters do |t|
      t.string :name
    end

    @sem = Semester.new
    @sem.name = "fall2015"
    @sem.save!

    @sem = Semester.new
    @sem.name = "spring2016"
    @sem.save!

    add_column :courses, :semester_id, :integer

    @sem = Semester.find_by(name: 'fall2015')
    Course.find_each do |course|
      course.semester = @sem
      course.save!
    end

  end
  def down
    drop_table :semesters
    remove_column :courses, :semester_id
  end
end
