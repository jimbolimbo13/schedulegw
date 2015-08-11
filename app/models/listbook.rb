class Listbook < ActiveRecord::Base
  before_save :get_info_from_amazon

  has_many :coursebooks
  has_many :courses, :through => :coursebooks

  def get_info_from_amazon
    # Only hit Amazon if something changed
    if self.changed?
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

      response = request.item_search(
        query: {
          'Keywords' => isbn,
          'SearchIndex' => 'Books'
        }
      )



      @doc = Nokogiri::XML(response.body)

      self.title = @doc.at_css('Items Item ItemAttributes Title').text unless @doc.css('Items Item ItemAttributes Title').empty?

      self.image_url = @doc.at_css('Items Item LargeImage URL').text unless @doc.css('Items Item LargeImage URL').empty?

      self.amzn_url = URI.unescape( @doc.at_css('Items Item DetailPageURL').text ) unless @doc.css('Items Item DetailPageURL').empty?


      sleep(2) # Amazon rate limit = 1 per second.
    end
  end

end
