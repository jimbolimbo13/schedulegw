class Course < ActiveRecord::Base
  after_save :add_to_listbooks

  #relationship to schedules
  has_many :courseschedules
  has_many :schedules, through: :courseschedules


  #possibly:
  belongs_to :schools

	has_many :subscriptions
	has_many :users, through: :subscriptions

  # Connecting Course to Listbooks
  has_many :coursebooks
  has_many :listbooks, :through => :coursebooks

	def self.scrape
    #load the scrapers here.
		load Dir.pwd + '/GWU_scrape.rb'
	end

  def next
    Course.where("id > ?", id).first.nil? ? Course.first : Course.where("id > ?", id).first
  end

  def previous
    Course.where("id < ?", id).first.nil? ? Course.last : Course.where("id < ?", id).first
  end

  # This needs to be modified to also subtract a course-book relation to handle cases when a book should NOT
  # be associated with a course
  def add_to_listbooks
    self.isbn.each do |isbn|
      book = Listbook.find_or_create_by(isbn: isbn)
      book.courses << self unless book.courses.include? self
      book.save!
    end
  end

  def self.get_books(url)
    yomu = Yomu.new url
    text = yomu.text
    final_text = text.gsub(/\n+/, " ")
    course_array = final_text.split(/\s(?=6\d{3}-\w{2,3})/)

    course_array.each do |course|
      gwid = course.match(/(6\d{3}-\w{2,3})/)
      gwid = gwid.to_s.slice(/((?:\w+-*)+)/)
      gwid != nil && gwid[5] != "A" ? (current_class = Course.find_or_create_by(gwid: gwid)) : next

      # Get the current isbns to compare to later to see if there's anything new.
      current_isbn = current_class.isbn

      isbn_array = course.scan(/(?<=ISBN-13):*\s*((?:\d+-*)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end
      isbn_array = course.scan(/(?<=ISBN[#:\s])\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end
      isbn_array = course.scan(/(?<=ISBN#:)\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end
      isbn_array = course.scan(/(?<=ISBN\sNumber:)\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end

      # Remove the ISBNs that we've already flagged as wrong.
      current_class.isbn = current_class.isbn - current_class.wrong_isbn.map {|i| i.to_s }

      # If the booklist is locked, note a conflict if a change is attempted. 
      current_class.update_attribute('booklist_lock_conflict', true) if ( current_class.isbn.sort != current_isbn.sort && current_class.booklist_locked )

      # Actually save the course unless its a locked record
      current_class.save! unless current_class.booklist_locked

    end
    # Update the coursebooks <--> listbooks
    Course.find_each do |course|
      course.add_to_listbooks unless course.isbn.empty?
    end
  end

end
