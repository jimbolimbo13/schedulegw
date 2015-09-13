task :mail_everyone => :environment do
  puts "syncing with Amazon ..."
  Listbook.sync_with_amazon
  puts "Sending Books Emails "
  User.find_each do |user|
   Usermailer.booksemail(user).deliver_now unless user.last_email_blast > 60.hours.ago
   puts "Emailed #{user.name}" unless user.last_email_blast > 60.hours.ago
  end
end
