class AddFinalDateandFinalTimetoCourse < ActiveRecord::Migration
  def change
  	add_column :courses, :final_date, :string
  	add_column :courses, :final_time, :string
  end
end
