class Add < ActiveRecord::Migration
  def change
  	add_column :courses, :schedule_id, :integer
  end
end
