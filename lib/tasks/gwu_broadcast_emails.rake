task :mail_everyone => :environment do
 puts "Sending Books Emails "


 User.find_each do |user|
   SendBooklistWorker.perform_async(user.id)
 end


end
