class Listbook < ActiveRecord::Base
  before_save :get_info_from_amazon

  has_many :coursebooks
  has_many :courses, :through => :coursebooks
  
  def get_info_from_amazon
    # Only hit Amazon if the isbn field changed.
    if isbn_changed?
      request = Vacuum.new
      request.configure(
        aws_access_key_id: ENV['aws_access_key_id'],
        aws_secret_access_key: ENV['aws_secret_access_key'],
        associate_tag: 'scgw-20'
      )

      response = request.item_search(
        query: {
          'Keywords' => self.isbn,
          'SearchIndex' => 'Books'
        }
      )
      @doc = Nokogiri::HTML(response.body)
      self.title = @doc.xpath("//title").children.to_s
      self.amzn_url = "http://www.amazon.com/s/?url=search-alias%3Daps&field-keywords=#{ self.isbn }&tag=scgw-20"
      sleep(1) # Amazon rate limit = 1 per second.
    end
  end

end
