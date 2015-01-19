desc "This task is called by the Heroku scheduler add-on"
task :GWU_scrape => :environment do
 puts "Running Scrape of GWU . . . "
 Course.GWU_scrape
 puts "Finished Scrape of GWU."
end

