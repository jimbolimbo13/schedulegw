class SendScheduleWorker
  include Sidekiq::Worker

  # To call this : SendScheduleWorker.perform_async(user_id, schedule_id)
  def perform(user_id, schedule_id)
    Usermailer.schedule(user_id, schedule_id).deliver_now
  end
end
