desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do
 puts "Running Scrape of courses for GWU. . . "
 Course.scrape
 puts "Finished Scrape."
 puts "Starting scrape of booklist for GWU"
 # Course.get_books("http://www.law.gwu.edu/Students/Records/Fall2015/Documents/Fall%202015%20Book%20List.pdf")
 puts "Finished getting books for GWU"
end
