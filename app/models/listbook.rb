class Listbook < ActiveRecord::Base
  before_save :update_if_changed

  has_many :coursebooks
  has_many :courses, :through => :coursebooks

  def self.sync_with_amazon
    Listbook.find_each do |book|
      book.get_info_from_amazon
      book.save!
    end
  end

  def sync_amazon_links
    Listbook.find_each do |book|
      book.get_info_from_amazon if book.amzn_url == nil
      book.save!
    end
  end


  def update_if_changed
    # Only hit Amazon if something changed
    self.get_info_from_amazon if self.changed?
  end

  def get_info_from_amazon
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

    @doc = Nokogiri::XML(response.body)

    self.title = @doc.at_css('Items Item ItemAttributes Title').text unless @doc.css('Items Item ItemAttributes Title').empty?

    self.image_url = @doc.at_css('Items Item LargeImage URL').text unless @doc.css('Items Item LargeImage URL').empty?

    self.amzn_url = URI.unescape( @doc.at_css('Items Item DetailPageURL').text ) unless @doc.css('Items Item DetailPageURL').empty?
    sleep(2) # Amazon rate limit = 1 per second.

  end

end
