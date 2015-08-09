class BooklistScraperWorker
  include Sidekiq::Worker

  # To call this : BooklistScraperWorker.perform_async(school_id)
  def perform(school_id)
    url = School.find(school_id).booklist_url
    Course.get_books(url)
  end

end
