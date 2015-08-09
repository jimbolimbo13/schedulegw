class SendBooklistWorker
  include Sidekiq::Worker

  # To call this : SendBooklistWorker.perform_async(user_id)
  def perform(user_id)
    user = User.find(user_id)
    Usermailer.booksemail(user).deliver_now
  end

end
