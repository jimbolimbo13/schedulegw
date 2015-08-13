class AddPopularityToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :schedule_count, :integer, default: 0
  end
end
