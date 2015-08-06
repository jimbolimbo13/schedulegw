class AddWrongIsbNstoCourses < ActiveRecord::Migration
  def up
    add_column :courses, :wrong_isbn, :json, unique: true, default: []
  end
end
