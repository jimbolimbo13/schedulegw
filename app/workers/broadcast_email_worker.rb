class BroadcastEmailWorker
  include Sidekiq::Worker

  # To call this : BroadcastEmailWorker.perform_async(user_id)
  def perform(round_number)
    # round is whether the email is the first, second, or third email blast.
    case round_number.to_i
    when 1
      Listbook.sync_with_amazon
      User.find_each do |user|
       Usermailer.booksemail1(user).deliver_now unless user.last_email_blast > 60.hours.ago
      end
    when 2
      Listbook.sync_with_amazon
      User.find_each do |user|
       Usermailer.booksemail2(user).deliver_now unless user.last_email_blast > 60.hours.ago
      end
    when 3
      Listbook.sync_with_amazon
      User.find_each do |user|
       Usermailer.booksemail3(user).deliver_now unless user.last_email_blast > 60.hours.ago
      end
    else
      puts "No Case Executed "
    end

  end

end
