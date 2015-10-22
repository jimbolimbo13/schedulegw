task :cleanup_spring2016 => :environment do
  puts "Assigning final times for Spring 2016"

  first_session = [
    [6342, 12],
    [6400, 11],
    [6870, 10],

    [6250, 12],
    [6268, 10],
    [6360, 10],
    [6362, 10],
    [6400, 12],
    [6871, 10],

    [6280, 10],
    [6298, 10],
    [6300, 11],
    [6473, 20],
    [6478, 10],
    [6520, 10],
    [6540, 10],

    [6218, 12],
    [6284, 10],
    [6497, 10],

    [6260, 10],
    [6304, 10],
    [6480, 10],
    [6532, 10],
    [6554, 10],
    [6616, 10],
    [6874, 10],

    [6252, 10],
    [6400, 13],

    [6601, 10],

    [6230, 11],
    [6449, 10],
    [6486, 10],

    [6218, 11],
    [6449, 10],
    [6486, 10],

    [6218, 11],
    [6230, 13],
    [6602, 10]

  ]

  second_session = [
    [6380, 12],
    [6534, 10],

    [6214, 11],
    [6214, 12],
    [6214, 13],
    [6214, 14],
    [6214, 15],

    [6250, 11],
    [6300, 12],
    [6342, 11],
    [6491, 10],

    [6208, 11],
    [6208, 12],
    [6208, 13],
    [6208, 14],
    [6208, 15],

    [6236, 10],
    [6354, 10],
    [6364, 10],
    [6471, 10],
    [6546, 10],
    [6595, 10],

    [6232, 10],
    [6254, 10],
    [6312, 10],
    [6384, 10],
    [6474, 10],
    [6545, 10],

    [6203, 11],
    [6203, 12],
    [6203, 13],
    [6203, 14],

    [6234, 10],
    [6238, 10],
    [6369, 10],

    [6213, 11],
    [6213, 12],
    [6213, 13],
    [6213, 14],

    [6230, 12],
    [6380, 11],
    [6538, 10]

  ]

  third_session = [
    [6266, 20],
    [6530, 20],
    [6871, 20],

    [6206, 21],
    [6231, 10],
    [6348, 20],
    [6360, 20],
    [6421, 20],
    [6482, 20],

    [6261, 20],
    [6285, 20],
    [6481, 20],

    [6300, 20],
    [6334, 20],
    [6408, 20],
    [6538, 20],
    [6542, 20],

    [6203, 21],
    [6380, 20],
    [6437, 20],
    [6474, 20],

    [6342, 20],
    [6380, 20],
    [6437, 20],
    [6474, 20],

    [6342, 20],
    [6402, 20],
    [6522, 20],

    [6400, 20],

    [6213, 21],
    [6389, 20],
    [6443, 20],
    [6503, 20]
  ]

  semester_id = Semester.find_by(name: "spring2016").id

  first_session.each do |dat|
    course = Course.find_by(gwid: dat[0], section: dat[1], semester_id: semester_id)
    course.final_time = School.find_by(name: "GWU").final_time_options.first
    course.locked_attributes << "final_time"
    course.save!
  end

  second_session.each do |dat|
    course = Course.find_by(gwid: dat[0], section: dat[1], semester_id: semester_id)
    course.final_time = School.find_by(name: "GWU").final_time_options.second
    course.locked_attributes << "final_time"
    course.save!
  end

  third_session.each do |dat|
    course = Course.find_by(gwid: dat[0], section: dat[1], semester_id: semester_id)
    course.final_time = School.find_by(name: "GWU").final_time_options.third
    course.locked_attributes << "final_time"
    course.save!
  end

  # Other Manual Edits. This is AKA list of things to fix.
  course = Course.find_by(course_name: "Evidence", professor: "Kirkpatrick", semester_id: semester_id)
  course.prof_id = 13830
  course.locked_attributes << "prof_id"
  course.save!




end
