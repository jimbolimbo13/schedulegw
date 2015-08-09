desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do
 puts "Running Scrape of courses for GWU. . . "
 Course.scrape
 puts "Finished Scrape."
 puts "Starting scrape of booklist for GWU"
 Course.get_books(School.find_by(name: "GWU").booklist_url)
 puts "Finished getting books for GWU"
end
