# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

school = School.find_or_initialize_by(name: 'none')
	school.display_name = "No School Associated With User"
	school.email_stub = "@gmail.com"
	school.initials = 'NA'
school.save!

school = School.find_or_initialize_by(name: 'GWU')
	school.display_name = "The George Washington University Law School"
	school.email_stub = "@law.gwu.edu"
	school.initials = 'GWU'
school.save!
