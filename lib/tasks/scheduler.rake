desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do
 puts "Running Scrape of courses for GWU. . . "
 Scraper.scrape_gwu!
 puts "Finished Scrape."
 puts "Did not scrape booklist!"
end
