class AddSemester < ActiveRecord::Migration
  def up
    create_table :semesters do |t|
      t.string :name
    end

    @sem1 = Semester.new
    @sem1.name = "fall2015"
    @sem1.save!

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

    # This table will replace a lot of the data previously held in School model.
    create_table :scrapeurls do |t|
      t.string :url, unique: true
      t.integer :school_id
      t.integer :semester_id
      t.string :name # the purpose of this URL. flexible b/c may vary by school.
      t.string :scrape_digest
      t.datetime :last_scraped
      t.datetime :last_checked
    end

    # Fill in/populate old data for previous scrapes and URLs
    @scrape_url = Scrapeurl.new
    @scrape_url.school = School.find_by(name: "GWU")
    @scrape_url.semester = @sem1
    @scrape_url.name = "crn_text"
    @scrape_url.url = 'http://www.law.gwu.edu/Students/Records/Fall2015/Documents/Fa15%20Schedule%20with%20CRNs.pdf'
    @scrape_url.last_checked = Time.now
    @scrape_url.last_scraped = Time.now
    @scrape_url.save!

    @scrape_url = Scrapeurl.new
    @scrape_url.school = School.find_by(name: "GWU")
    @scrape_url.semester = @sem1
    @scrape_url.name = "exam_text"
    @scrape_url.url = 'http://www.law.gwu.edu/Students/Records/Fall2015/Documents/Fall%202015%20Schedule%20with%20Exams.pdf'
    @scrape_url.last_checked = Time.now
    @scrape_url.last_scraped = Time.now
    @scrape_url.save!


  end
  def down
    drop_table :semesters
    drop_table :scrapeurls
    remove_column :courses, :semester_id
    remove_column :schools, :semester_id
  end
end
