class AddPinnedisbntoCourse < ActiveRecord::Migration
  def change
    add_column :courses, :pinned_isbn, :json, unique: true, default: []
  end
end
