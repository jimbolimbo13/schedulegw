class AddScrapeHashtoSchool < ActiveRecord::Migration
  def up
    add_column :schools, :crn_scrape_digest, :string
    add_column :schools, :crn_last_scraped, :datetime
    add_column :schools, :crn_last_checked, :datetime

    add_column :schools, :exam_scrape_digest, :string
    add_column :schools, :exam_last_scraped, :datetime
    add_column :schools, :exam_last_checked, :datetime

    add_column :schools, :booklist_scrape_digest, :string
    add_column :schools, :booklist_last_scraped, :datetime
    add_column :schools, :booklist_last_checked, :datetime
  end

  def down
    remove_column :schools, :crn_scrape_digest
    remove_column :schools, :crn_last_scraped
    remove_column :schools, :crn_last_checked

    remove_column :schools, :exam_scrape_digest
    remove_column :schools, :exam_last_scraped
    remove_column :schools, :exam_last_checked

    remove_column :schools, :booklist_scrape_digest
    remove_column :schools, :booklist_last_scraped
    remove_column :schools, :booklist_last_checked
  end
end
