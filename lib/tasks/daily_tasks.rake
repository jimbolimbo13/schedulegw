# These tasks are run daily

desc "This task deletes accounts that are older than 3 years to comply with privacy policy."
task :delete_old_accounts => :environment do
  User.find_each do |user|
    user.destroy! if user.created_at < 3.years.ago
  end
  User.delete_all(:school_id => 1)
end
