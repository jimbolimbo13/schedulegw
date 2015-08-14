task :mail_everyone => :environment do
  puts "Sending Books Emails "
  User.find_each do |user|
   Usermailer.booksemail(user).deliver_now unless user.last_email_blast > 60.hours.ago
  end
end


task :manual_fix => :environment do
  puts "Manually Marking those that already received an email today.  "

   emailed = [ "Danniyal Ahmed",
   "Natasha Baker",
   "Kavon Khani",
   "Rebecca Bonnarens",
   "Jeremy Buday",
   "Chelsea Kirkpatrick",
   "Sung Won Yoon",
   "Nikki Keeley",
   "Zachariah Johnson",
   "Heba Dafashy",
   "Le Andrew Nguyen",
   "Chanell Khosrowabadi",
   "John Werner",
   "James Rippeon",
   "Laura Seferian",
   "Vanessa Hernandez-martinez",
   "Michael Carpenter",
   "Haleigh Amant",
   "Christopher Bair",
   "Tabatha Blake",
   "Joseph Tharp",
   "Ana Morales Murrieta",
   "Micaela Cohen",
   "Samantha Lewis",
   "James Whittle",
   "Dennis Hui",
   "Jennifer Junger",
   "Natalee Allenbaugh",
   "Robert Pollak",
   "Zachary Andrews",
   "Bud Davis",
   "Jeffrey DePaso",
   "Corinne Rockoff",
   "Nathan Delmar"
   ]

   modified = 0
   error_names = []

   emailed.each do |name|
     user = User.find_by(name: name)

    if user
      user.last_email_blast = Time.now
      modified = modified + 1 if user.save!
     else
       error_names << name
     end
   end

   puts "Users in array: #{emailed.count}"
   puts "Users marked as already received (should match): #{modified}"
   puts "Names not mapped to a user: #{error_names.inspect}"

end
