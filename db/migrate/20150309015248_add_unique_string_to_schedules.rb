class AddUniqueStringToSchedules < ActiveRecord::Migration
  def up
    add_column :schedules, :unique_string, :string
  end
  def down
    remove_column :schedules, :unique_string
  end
end
