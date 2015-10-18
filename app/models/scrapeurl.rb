class Scrapeurl < ActiveRecord::Base
  belongs_to :school
  belongs_to :semester


  # Compare hash of the new source with the one on file.
  def source_changed?
    new_text = Yomu.new self.url
    new_text = new_text.text
    new_digest = Digest::MD5.hexdigest new_text

    # Return true if different, false if the same
    new_digest == self.scrape_digest ? false : true
  end

  def update_digest
    new_text = Yomu.new self.url
    self.scrape_digest = Digest::MD5.hexdigest new_text.text
    self.save!
  end



end
