class AddDefaultsToSchoolModel < ActiveRecord::Migration
  def change
    change_column :schools, :crn_scrape_digest, :string, :default => ""
    change_column :schools, :crn_last_scraped, :datetime, :default => Time.now
    change_column :schools, :crn_last_checked, :datetime, :default => Time.now

    change_column :schools, :exam_scrape_digest, :string, :default => ""
    change_column :schools, :exam_last_scraped, :datetime, :default => Time.now
    change_column :schools, :exam_last_checked, :datetime, :default => Time.now

    change_column :schools, :booklist_scrape_digest, :string, :default => ""
    change_column :schools, :booklist_last_scraped, :datetime, :default => Time.now
    change_column :schools, :booklist_last_checked, :datetime, :default => Time.now
  end
end
