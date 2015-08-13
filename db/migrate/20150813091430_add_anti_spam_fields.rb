class AddAntiSpamFields < ActiveRecord::Migration
  def change
    add_column :users, :last_email_blast, :datetime, default: 3.days.ago
  end
end
