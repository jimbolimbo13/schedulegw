task :mail_everyone => :environment do
  puts "Sending Books Emails "
  User.find_each do |user|
   Usermailer.booksemail(user).deliver_now unless user.last_email_blast > 60.hours.ago
   puts "Emailed #{user.name}" unless user.last_email_blast > 60.hours.ago
  end
end

# Removes from the email list emails that bounce
task :remove_invalid_accounts => :environment do
  invalid_emails = [
     'agreenberg@law.gwu.edu',
      'jmgottesman@law.gwu.edu',
      'joh@law.gwu.edu',
      'sking2@law.gwu.edu',
      'rgagne@law.gwu.edu',
      'abaze@law.gwu.edu',
      'mlarywon@law.gwu.edu',
      'kbergin@law.gwu.edu',
      'lmorgenstern@law.gwu.edu',
      'kpowderly@law.gwu.edu',
      'jpickar@law.gwu.edu',
      'choughton@law.gwu.edu',
      'ini@law.gwu.edu',
      'pafuller@law.gwu.edu',
      'ehanzich@law.gwu.edu',
      'emwajert@law.gwu.edu',
      'kyukevich@law.gwu.edu',
      'daluise@law.gwu.edu',
      'ckhosrowabadi@law.gwu.edu'
  ]

  invalid_emails.each do |email|
    u = User.find_by(email: email)
    u.destroy! unless u.nil?
  end

end
