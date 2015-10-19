class Addlockedattributestocourses < ActiveRecord::Migration
  def up
    add_column :courses, :locked_attributes, :json, default: []
  end
  def down
    remove_column :courses, :locked_attributes
  end
end
