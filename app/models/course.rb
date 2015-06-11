class Course < ActiveRecord::Base

  #relationship to schedules
  has_many :courseschedules
  has_many :schedules, through: :courseschedules


  #possibly:
  belongs_to :schools

	has_many :subscriptions
	has_many :users, through: :subscriptions


	

	def self.scrape
    #load the scrapers here.
		load Dir.pwd + '/GWU_scrape.rb'
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
      
      isbn_array = course.scan(/(?<=ISBN-13):*\s*((?:\d+-*)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          if current_class.isbn.include? book
            next
          else 
            current_class.isbn << book
          end
          current_class.save!
        end
      end
      isbn_array = course.scan(/(?<=ISBN[#:\s])\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          if current_class.isbn.include? book
            next
          else 
            current_class.isbn << book
          end
          current_class.save!
        end
      end
      isbn_array = course.scan(/(?<=ISBN#:)\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          if current_class.isbn.include? book
            next
          else 
            current_class.isbn << book
          end
          current_class.save!
        end
      end
      isbn_array = course.scan(/(?<=ISBN\sNumber:)\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          if current_class.isbn.include? book
            next
          else 
            current_class.isbn << book
          end
          current_class.save!
        end
      end
    end

  end

end
