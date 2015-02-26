class AddSchoolToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :school, :string
  end
end
