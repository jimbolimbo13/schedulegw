class AddEmailsSenttoSchools < ActiveRecord::Migration
  def up
    add_column :schools, :emails_sent, :integer, default: 0
    add_column :schools, :schedules_created, :integer, default: 0
  end
  def down
    remove_column :schools, :emails_sent
    remove_column :schools, :schedules_created
  end
end
